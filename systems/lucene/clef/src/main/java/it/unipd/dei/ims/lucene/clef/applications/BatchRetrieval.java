package it.unipd.dei.ims.lucene.clef.applications;

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import it.unipd.dei.ims.lucene.clef.AnalyzerFactory;
import it.unipd.dei.ims.lucene.clef.parser.ClefQQParser;
import org.apache.lucene.analysis.util.CharArraySet;
import org.apache.lucene.benchmark.quality.QualityBenchmark;
import org.apache.lucene.benchmark.quality.QualityQuery;
import org.apache.lucene.benchmark.quality.QualityQueryParser;
import org.apache.lucene.benchmark.quality.QualityStats;
import org.apache.lucene.benchmark.quality.utils.SubmissionReport;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.similarities.BM25Similarity;
import org.apache.lucene.search.similarities.Similarity;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.SimpleFSDirectory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;


/**
 *
 *  Functionalities to perform the evaluation of ad-hoc test collections.
 *
 */
public class BatchRetrieval {

    static Logger logger = LoggerFactory.getLogger(BatchRetrieval.class);

    public static void main(String [] args) {

        Properties properties = new Properties();
        InputStream input = null;
        try {
            if (System.getProperty("properties.path")!=null) {
                input = new FileInputStream(System.getProperty("properties.path"));
                properties.load(input);
            } else {
                logger.info("Loading default property file [resources/lucene-clef.properties]");
                ClassLoader loader = Thread.currentThread().getContextClassLoader();
                input = loader.getResourceAsStream("lucene-clef.properties");
                properties.load(input);
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        properties.putAll(System.getProperties());

        Path indexPath = new File(properties.getProperty("index.path")).toPath();

        Path runPath = new File(properties.getProperty("run.path")).toPath();

        String runTag = properties.getProperty("run.tag");

        String language = properties.getProperty("language");

        String stemmer = properties.getProperty("stemmer");

        String stopsetType = properties.getProperty("stopset.type");

        String stopsetPath = properties.getProperty("stopset.path");

        try {

            Directory directory = new SimpleFSDirectory(indexPath);
            IndexReader reader = DirectoryReader.open(directory);
            IndexSearcher searcher = new IndexSearcher(reader);

            String model = properties.getProperty("run.model").toUpperCase();

            Similarity similarity;

            switch (model) {
                case "BM25":
                    similarity=new BM25Similarity(
                            Float.parseFloat(properties.getProperty("bm25.k1","1.2f")),
                            Float.parseFloat(properties.getProperty("bm25.b","0.75f"))
                    );
                    break;
                default:
                    throw new UnsupportedOperationException("Model " + model + " not supported yet");

            }

            searcher.setSimilarity(similarity);

            int maxResults = Integer.parseInt(properties.getProperty("maxresults","1000"));

            SubmissionReport runfile = new SubmissionReport(
                    new PrintWriter(Files.newBufferedWriter(runPath, StandardCharsets.UTF_8)), model);

            String topicPath = properties.getProperty("topics.path");

            String [] topicFields = properties.getProperty("topics.fields").split(";");

            CharArraySet stopset = AnalyzerFactory.createStopset(language, stopsetType, stopsetPath);

            QualityQuery qqs[] = getQualityQueries(topicPath,topicFields);

            QualityQueryParser qqParser = new ClefQQParser(
                    topicFields,
                    BuildIndex.BODY_FIELD_NAME,
                    language,
                    stemmer,
                    stopset
            );

            // run the benchmark
            QualityBenchmark qrun = new QualityBenchmark(qqs, qqParser, searcher, BuildIndex.ID_FIELD_NAME);

            qrun.setMaxResults(maxResults);

            QualityStats stats[] = qrun.execute(null, runfile, null);

            reader.close();
            directory.close();

        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }


    public static QualityQuery [] getQualityQueries(String topicPath, String [] topicFields) throws Exception {

        File fXmlFile = new File(topicPath);
        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder = null;
        try {
            dBuilder = dbFactory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            e.printStackTrace();
            throw new Exception("ParserConfigurationException when parsing topic file "+topicPath);
        }
        org.w3c.dom.Document doc = null;
        try {
            doc = dBuilder.parse(fXmlFile);
        } catch (SAXException e) {
            e.printStackTrace();
            throw new Exception("SAXException when parsing topic file "+topicPath);
        } catch (IOException e) {
            e.printStackTrace();
            throw new Exception("IOException when parsing topic file "+topicPath);
        }

        doc.getDocumentElement().normalize();

        NodeList nList = doc.getElementsByTagName("topic");

        QualityQuery [] qqs = new QualityQuery[nList.getLength()];

        for (int i = 0; i < nList.getLength(); i++) {

            Node nNode = nList.item(i);

            if (nNode.getNodeType() == Node.ELEMENT_NODE) {

                Element eElement = (Element) nNode;

                String queryId = eElement.getElementsByTagName("identifier").item(0).getTextContent();
                Map<String,String> queryFields = new HashMap<String,String>();
                for (String topicField : topicFields){
                    queryFields.put(
                        topicField,
                        eElement.getElementsByTagName(topicField).item(0).getTextContent()
                    );
                }

                qqs[i] = new QualityQuery(
                    queryId,
                    queryFields
                );

            }

        }

        return qqs;

    }


}
