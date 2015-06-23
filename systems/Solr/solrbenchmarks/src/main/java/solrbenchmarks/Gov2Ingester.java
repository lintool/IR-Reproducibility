package solrbenchmarks;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

import org.apache.lucene.benchmark.byTask.feeds.DocData;
import org.apache.lucene.benchmark.byTask.feeds.NoMoreDataException;
import org.apache.lucene.benchmark.byTask.feeds.TrecContentSource;
import org.apache.lucene.benchmark.byTask.utils.Config;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.ConcurrentUpdateSolrClient;
import org.apache.solr.common.SolrInputDocument;


public class Gov2Ingester {
  public static void main(String[] args) throws FileNotFoundException, IOException {
    if(args.length != 2) {
      System.out.println("Usage: <parser> datadir solrUrl");
      System.exit(1);
    }
    String dataDir = args[0];
    String solrUrl = args[1];
    
    long start = System.currentTimeMillis();

    ConcurrentUpdateSolrClient css = new ConcurrentUpdateSolrClient(solrUrl, 32000, 8);

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

          SolrInputDocument doc = new SolrInputDocument();
          doc.setField("id", dd.getName());
          doc.setField("title_t", dd.getTitle());
          doc.setField("body_t", dd.getBody());
          css.add(doc);

          if (counter%5000==0) {
            css.commit();
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
        css.commit();
      } catch (SolrServerException e) {
        e.printStackTrace();
      }
      
      System.out.println("Time: "+(System.currentTimeMillis()-start)/1000+" seconds");

      css.close();
    }
  }
}
