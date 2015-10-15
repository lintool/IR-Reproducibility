package it.unipd.dei.ims.lucene.clef;

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

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.bg.BulgarianAnalyzer;
import org.apache.lucene.analysis.de.GermanAnalyzer;
import org.apache.lucene.analysis.es.SpanishAnalyzer;
import org.apache.lucene.analysis.fa.PersianAnalyzer;
import org.apache.lucene.analysis.fi.FinnishAnalyzer;
import org.apache.lucene.analysis.fr.FrenchAnalyzer;
import org.apache.lucene.analysis.hu.HungarianAnalyzer;
import org.apache.lucene.analysis.it.ItalianAnalyzer;
import org.apache.lucene.analysis.nl.DutchAnalyzer;
import org.apache.lucene.analysis.pt.PortugueseAnalyzer;
import org.apache.lucene.analysis.ru.RussianAnalyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.sv.SwedishAnalyzer;
import org.apache.lucene.analysis.util.CharArraySet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

/**
 * Factory for {@link org.apache.lucene.analysis.Analyzer}s and stopsets.
 */
public class AnalyzerFactory {

    static Logger logger = LoggerFactory.getLogger(AnalyzerFactory.class);

    public static CharArraySet createStopset(
            String language,
            String stopsetType,
            String stopsetPath
    ) throws Exception {

        CharArraySet stopset = CharArraySet.EMPTY_SET;

        if (stopsetType.equalsIgnoreCase("CUSTOM")){

            try {
                File f = new File(stopsetPath);
                stopset = new CharArraySet(0,true);
                Scanner sc = new Scanner(f);
                logger.debug("STOPLIST:");
                while (sc.hasNextLine()) {
                    String stopword = sc.nextLine().trim();
                    logger.debug("=> "+stopword);
                    stopset.add(stopword);
                }
                logger.debug("");
                sc.close();

            } catch (FileNotFoundException e) {
                e.printStackTrace();
                throw new Exception("FileNotFoundException when loading stopset");
            }

        } else if (stopsetType.equalsIgnoreCase("DEFAULT")){

            switch (language) {
                case "bg":
                    stopset = BulgarianAnalyzer.getDefaultStopSet();
                    break;
                case "de":
                    stopset = GermanAnalyzer.getDefaultStopSet();
                    break;
                case "es":
                    stopset = SpanishAnalyzer.getDefaultStopSet();
                    break;
                case "fa":
                    stopset = PersianAnalyzer.getDefaultStopSet();
                    break;
                case "fi":
                    stopset = FinnishAnalyzer.getDefaultStopSet();
                    break;
                case "fr":
                    stopset = FrenchAnalyzer.getDefaultStopSet();
                    break;
                case "hu":
                    stopset = HungarianAnalyzer.getDefaultStopSet();
                    break;
                case "it":
                    stopset = ItalianAnalyzer.getDefaultStopSet();
                    break;
                case "nl":
                    stopset = DutchAnalyzer.getDefaultStopSet();
                    break;
                case "pt":
                    stopset = PortugueseAnalyzer.getDefaultStopSet();
                    break;
                case "ru":
                    stopset = RussianAnalyzer.getDefaultStopSet();
                    break;
                case "sv":
                    stopset = SwedishAnalyzer.getDefaultStopSet();
                    break;
                default:
                    throw new UnsupportedOperationException("Language not supported yet");
            }

        }

        return stopset;
    }



    public static Analyzer createAnalyzer(
            String language,
            String stemmer,
            CharArraySet stopset
    ) {

        Analyzer analyzer;

        if (stemmer.equalsIgnoreCase("NONE")){

            analyzer = new StandardAnalyzer(stopset);

        } else { // otherwise use language-specific analyzer

            switch (language) {
                case "bg":
                    analyzer = new BulgarianAnalyzer(stopset);
                    break;
                case "de":
                    analyzer = new GermanAnalyzer(stopset);
                    break;
                case "es":
                    analyzer = new SpanishAnalyzer(stopset);
                    break;
                case "fa":
                    analyzer = new PersianAnalyzer(stopset);
                    break;
                case "fi":
                    analyzer = new FinnishAnalyzer(stopset);
                    break;
                case "fr":
                    analyzer = new FrenchAnalyzer(stopset);
                    break;
                case "hu":
                    analyzer = new HungarianAnalyzer(stopset);
                    break;
                case "it":
                    analyzer = new ItalianAnalyzer(stopset);
                    break;
                case "nl":
                    analyzer = new DutchAnalyzer(stopset);
                    break;
                case "pt":
                    analyzer = new PortugueseAnalyzer(stopset);
                    break;
                case "ru":
                    analyzer = new RussianAnalyzer(stopset);
                    break;
                case "sv":
                    analyzer = new SwedishAnalyzer(stopset);
                    break;
                default:
                    throw new UnsupportedOperationException("Language not supported yet");
            }

        }

        return analyzer;

    }


}
