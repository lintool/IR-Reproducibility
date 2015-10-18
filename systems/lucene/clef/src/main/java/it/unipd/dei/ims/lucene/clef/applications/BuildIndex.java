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
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.util.CharArraySet;
import org.apache.lucene.benchmark.byTask.feeds.DocData;
import org.apache.lucene.benchmark.byTask.feeds.NoMoreDataException;
import org.apache.lucene.benchmark.byTask.feeds.TrecContentSource;
import org.apache.lucene.benchmark.byTask.utils.Config;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.FieldType;
import org.apache.lucene.document.StringField;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexOptions;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.search.similarities.BM25Similarity;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.SimpleFSDirectory;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.util.Properties;

/**
 *
 * Functionalities to index CLEF test collections with Apache Lucene.
 *
 */
public class BuildIndex {

    static org.slf4j.Logger logger = LoggerFactory.getLogger(BuildIndex.class);

    public static String ID_FIELD_NAME="ID";
    public static String BODY_FIELD_NAME="BODY";

    public static void main(String [] args){

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

        String language = properties.getProperty("language");

        String stemmer = properties.getProperty("stemmer");

        String stopsetType = properties.getProperty("stopset.type");

        String stopsetPath = null;
        if (stopsetType.equalsIgnoreCase("CUSTOM")) {
            stopsetPath = properties.getProperty("stopset.path");
        }

        String corporaRootPath = properties.getProperty("corpora.path");

        int corpusSize = Integer.parseInt(properties.getProperty(language + ".corpus.size"));

        String [] corpora = properties.getProperty(language+".corpora").split(";");

        TrecContentSource trecContentSource = new TrecContentSource();

        try {

            Properties configProps = new Properties();
            configProps.setProperty("trec.doc.parser", "it.unipd.dei.ims.lucene.clef.parser.ClefDocParser");
            configProps.setProperty("content.source.verbose", "false");
            configProps.setProperty("content.source.forever", "false");
            configProps.setProperty("content.source.excludeIteration", "true");
            configProps.setProperty("work.dir", new File(".").getAbsolutePath());
            configProps.setProperty("language",language);
            configProps.setProperty("stemmer",stemmer);
            configProps.setProperty("stopset_type",stopsetType);
            configProps.setProperty("stopset_path",stopsetPath);

            // set lucene index directory
            Path indexPath = new File(properties.getProperty("index.path")).toPath();
            Directory directory = new SimpleFSDirectory(indexPath);

            // indexing configuration

            CharArraySet stopset = AnalyzerFactory.createStopset(language, stopsetType, stopsetPath);

            Analyzer analyzer = AnalyzerFactory.createAnalyzer(language,stemmer,stopset);

            IndexWriterConfig conf = new IndexWriterConfig(analyzer);
            conf.setSimilarity(new BM25Similarity());
            conf.setOpenMode(IndexWriterConfig.OpenMode.CREATE);

            IndexWriter indexWriter = new IndexWriter(directory, conf);
            boolean storePositions = true;
            FieldType bodyFieldType = new FieldType();
            if (storePositions){
                bodyFieldType.setIndexOptions(IndexOptions.DOCS_AND_FREQS_AND_POSITIONS_AND_OFFSETS);
            } else {
                bodyFieldType.setIndexOptions(IndexOptions.DOCS_AND_FREQS);
            }

            for (String corpus : corpora){

                int docCount = 0;

                logger.info("... indexing corpus " + corpus);

                try {

                    configProps.setProperty("docs.dir", corporaRootPath + "/"+corpus);

                    configProps.setProperty(
                        "content.source.encoding",
                        properties.getProperty(corpus+".encoding","UTF-8")
                    );

                    trecContentSource.setConfig(new Config(configProps));

                    DocData docData=new DocData();
                    while ((docData = trecContentSource.getNextDocData(docData)) != null) {
                        docCount++;
//                    System.out.println("ID: "+docData.getName());
//                    System.out.println("BODY: "+docData.getBody());
                        Document doc = getDocumentFromDocData(docData, bodyFieldType);
                        indexWriter.addDocument(doc);
                    }

                } catch (NoMoreDataException e) {
                    logger.info("... "+docCount+" documents indexed for corpus "+corpus+"\n");
                }

            }

            indexWriter.close();

            DirectoryReader ireader = DirectoryReader.open(directory);
            if (corpusSize != ireader.numDocs()){
                throw new Exception("The number of documents indexed is "+ireader.numDocs()+", but should be "+corpusSize);
            }
            logger.info("Number of documents: "+ireader.numDocs());

        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public static Document getDocumentFromDocData(DocData docData, FieldType bodyFieldType){

        Document doc = new Document();

        // add identifier field
        doc.add(new StringField(BuildIndex.ID_FIELD_NAME, docData.getName(), Field.Store.YES));

        // add body field
        doc.add(new Field(BuildIndex.BODY_FIELD_NAME,docData.getBody(),bodyFieldType));

        return doc;

    }

}
