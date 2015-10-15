package it.unipd.dei.ims.lucene.clef.parser;

import it.unipd.dei.ims.lucene.clef.applications.BatchRetrieval;
import org.apache.lucene.benchmark.quality.QualityQuery;
import org.junit.Test;

import java.io.File;

/**
 * Test of the parser for the CLEF Topics.
 *
 * @author Emanuele Di Buccio
 */
public class ClefQQParserTest {

    public static String [] langs = {
            "bg",
            "de",
            "es",
            "fa",
            "fi",
            "fr",
            "hu",
            "it",
            "nl",
            "pt",
            "ru",
            "sv"
    };

    public static String [] topicFields = {
            "title",
            "description"
    };

    @Test
    public void testClefTopicParser(){

        for (String lang : langs){

            ClassLoader classLoader = getClass().getClassLoader();
            File topicFile = new File(classLoader.getResource("topics/"+lang+"_topics.xml").getFile());

            try {
                QualityQuery[] qqs = BatchRetrieval.getQualityQueries(topicFile.getAbsolutePath(), topicFields);
                System.out.println("LANGUAGE: "+lang);
                for (QualityQuery qq : qqs){
                    System.out.println(qq.getQueryID());
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

        }

    }

}
