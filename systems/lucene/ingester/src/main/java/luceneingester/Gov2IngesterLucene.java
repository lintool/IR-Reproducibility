package luceneingester;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Properties;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.benchmark.byTask.feeds.DocData;
import org.apache.lucene.benchmark.byTask.feeds.NoMoreDataException;
import org.apache.lucene.benchmark.byTask.feeds.TrecContentSource;
import org.apache.lucene.benchmark.byTask.utils.Config;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field.Store;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;


public class Gov2IngesterLucene {
  public static void main(String[] args) throws FileNotFoundException, IOException {
    if(args.length != 2) {
      System.out.println("Usage: <parser> datadir luceneDir");
      System.exit(1);
    }
    String dataDir = args[0];
    String luceneDir = args[1];
    
    long start = System.currentTimeMillis();

    Directory dir = FSDirectory.open(Paths.get(luceneDir));
    StandardAnalyzer analyzer = new StandardAnalyzer();
    IndexWriterConfig conf = new IndexWriterConfig(analyzer);
    IndexWriter iw = new IndexWriter(dir, conf);
    
    try (TrecContentSource tcs = new TrecContentSource()) {
      Properties props = new Properties();
      props.setProperty("print.props", "false");
      props.setProperty("content.source.verbose", "false");
      props.setProperty("content.source.excludeIteration", "true");
      props.setProperty("docs.dir", dataDir);
      props.setProperty("trec.doc.parser", "org.apache.lucene.benchmark.byTask.feeds.TrecGov2Parser");
      props.setProperty("content.source.forever", "false");
      tcs.setConfig(new Config(props));
      tcs.resetInputs();
      DocData dd = new DocData();

      int counter = 0;
      long batchStartTime = start;
      while (true) {
        try {
          counter++;
          dd = tcs.getNextDocData(dd);

          Document doc = new Document();
          doc.add(new StringField("docname", dd.getName(), Store.YES));
          doc.add(new TextField("title", dd.getTitle(), Store.YES));
          doc.add(new TextField("body", dd.getBody(), Store.YES));
          iw.addDocument(doc);

          if (counter%10000==0) {
            iw.commit();
            System.out.println(counter+": "+dd.getName()+": "+dd.getTitle()+"\tbatch time: "+(System.currentTimeMillis()-batchStartTime)/1000+" seconds"+", total time: "+(System.currentTimeMillis()-start)/1000+" seconds");
            batchStartTime = System.currentTimeMillis();
          }
        } catch (IOException ex) {
          // The HTML parser used with this trec parser doesn't support HTML pages with framesets.
          if(!(ex.getCause()!=null && ex.getCause().getMessage().contains("HTML framesets") )) {
            System.err.println("Failed: "+ex.getMessage());
          }
        } catch (Exception e) {
          if(e instanceof NoMoreDataException) {
            break;
          } else {
            System.err.println("Failed: "+e.getMessage());
          }
        }
      }

    } finally {
      try {
        iw.commit();
      } catch (Exception e) {
        e.printStackTrace();
      }
      
      System.out.println("Time: "+(System.currentTimeMillis()-start)/1000+" seconds");

      iw.close();
    }
  }
}
