package luceneingester;

import java.io.File;
import java.io.IOException;

import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.Fields;
import org.apache.lucene.index.MultiFields;
import org.apache.lucene.index.Terms;
import org.apache.lucene.store.FSDirectory;

public class IndexStats {
	public static void main(String[] args) throws IOException {
		String indexPath = args[0];
		String field = args[1];
		
		DirectoryReader reader = (DirectoryReader.open(FSDirectory.open(new File(indexPath).toPath())));

		Fields fields = MultiFields.getFields(reader);
		Terms terms = fields.terms(field);
		System.out.println("Unique terms: "+terms.size());
		System.out.println("Sum doc freq: "+reader.getSumDocFreq(field));
		System.out.println("Sum total term freq: "+reader.getSumTotalTermFreq(field));

	}
}
