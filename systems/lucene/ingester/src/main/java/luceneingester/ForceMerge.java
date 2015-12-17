package luceneingester;

import java.io.IOException;
import java.nio.file.Paths;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.en.EnglishAnalyzer;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

public class ForceMerge {
	public static void main(String[] args) throws IOException {
		String indexPath = args[0];
	    final Analyzer a = new EnglishAnalyzer();
	    final Directory dir = FSDirectory.open(Paths.get(indexPath));

	    final IndexWriterConfig iwc = new IndexWriterConfig(a);
	    iwc.setOpenMode(IndexWriterConfig.OpenMode.APPEND);
	    final IndexWriter w = new IndexWriter(dir, iwc);
	    long start = System.currentTimeMillis();
	    w.forceMerge(1);
	    System.out.println("Merged.. Took: "+((System.currentTimeMillis())-start)/1000+" secs");
	    start = System.currentTimeMillis();
	    w.commit();
	    System.out.println("Committed.. Took: "+((System.currentTimeMillis())-start)/1000+" secs");
	    w.close();
	}
}

