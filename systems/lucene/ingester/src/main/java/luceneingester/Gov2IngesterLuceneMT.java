package luceneingester;

/**
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

import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Random;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.en.EnglishAnalyzer;
import org.apache.lucene.benchmark.byTask.feeds.TrecContentSource;
import org.apache.lucene.benchmark.byTask.utils.Config;
import org.apache.lucene.index.*;
import org.apache.lucene.store.*;
import org.apache.lucene.util.*;

// javac -Xlint:deprecation -cp ../modules/analysis/build/common/classes/java:build/classes/java:build/classes/test-framework:build/classes/test:build/contrib/misc/classes/java perf/Indexer.java perf/LineFileDocs.java

public final class Gov2IngesterLuceneMT {

  private static TrecContentSource getTrecSource(String dataDir) {
    TrecContentSource tcs = new TrecContentSource();
    Properties props = new Properties();
    props.setProperty("print.props", "false");
    props.setProperty("content.source.verbose", "false");
    props.setProperty("content.source.excludeIteration", "true");
    props.setProperty("docs.dir", dataDir);
    props.setProperty("trec.doc.parser", "org.apache.lucene.benchmark.byTask.feeds.TrecGov2Parser");
    props.setProperty("content.source.forever", "false");
    tcs.setConfig(new Config(props));
    try {
      tcs.resetInputs();
    } catch (IOException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    return tcs;
  }

  public static void main(String[] clArgs) throws Exception {

    Args args = new Args(clArgs);

    final String dirPath = args.getString("-indexPath") + "/index";

    final Directory dir = FSDirectory.open(Paths.get(dirPath));

    final Analyzer a = new EnglishAnalyzer();

    final String dataDir = args.getString("-dataDir");
    final TrecContentSource trecSource = getTrecSource(dataDir);
    
    // -1 means all docs in the line file:
    final int docCountLimit = args.getInt("-docCountLimit");
    final int numThreads = args.getInt("-threadCount");

    final boolean verbose = args.getFlag("-verbose");

    //final double ramBufferSizeMB = args.getDouble("-ramBufferMB");
    //final int maxBufferedDocs = args.getInt("-maxBufferedDocs");

    final boolean printDPS = args.getFlag("-printDPS");
    final boolean doUpdate = args.getFlag("-update");

    args.check();

    System.out.println("Index path: " + dirPath);
    System.out.println("Doc count limit: " + (docCountLimit == -1 ? "all docs" : ""+docCountLimit));
    System.out.println("Threads: " + numThreads);
    System.out.println("Verbose: " + (verbose ? "yes" : "no"));
    //System.out.println("RAM Buffer MB: " + ramBufferSizeMB);
    //System.out.println("Max buffered docs: " + maxBufferedDocs);
    
    if (verbose) {
      InfoStream.setDefault(new PrintStreamInfoStream(System.out));
    }

    final IndexWriterConfig iwc = new IndexWriterConfig(a);

    if (doUpdate) {
      iwc.setOpenMode(IndexWriterConfig.OpenMode.APPEND);
    } else {
      iwc.setOpenMode(IndexWriterConfig.OpenMode.CREATE);
    }

    //iwc.setMaxBufferedDocs(maxBufferedDocs);
    //iwc.setRAMBufferSizeMB(ramBufferSizeMB);

    System.out.println("IW config=" + iwc);

    final IndexWriter w = new IndexWriter(dir, iwc);

    // Fixed seed so group field values are always consistent:
    final Random random = new Random(17);

    IndexThreads threads = new IndexThreads(random, w, trecSource,
                                            numThreads, docCountLimit, printDPS,
                                            -1.0f, false);

    System.out.println("\nIndexer: start");
    final long t0 = System.currentTimeMillis();

    threads.start();

    while (!threads.done()) {
      Thread.sleep(100);
    }

    threads.stop();

    final long t1 = System.currentTimeMillis();
    System.out.println("\nIndexer: indexing done (" + (t1-t0) + " msec); total " + w.maxDoc() + " docs");
    // if we update we can not tell how many docs
    if (!doUpdate && docCountLimit != -1 && w.maxDoc() != docCountLimit) {
      throw new RuntimeException("w.maxDoc()=" + w.maxDoc() + " but expected " + docCountLimit);
    }
    if (threads.failed.get()) {
      throw new RuntimeException("exceptions during indexing");
    }


    final long t2;
    t2 = System.currentTimeMillis();

    final Map<String,String> commitData = new HashMap<String,String>();
    commitData.put("userData", "multi");
    w.setCommitData(commitData);
    w.commit();
    final long t3 = System.currentTimeMillis();
    System.out.println("\nIndexer: commit multi (took " + (t3-t2) + " msec)");

    System.out.println("\nIndexer: at close: " + w.segString());
    final long tCloseStart = System.currentTimeMillis();
    w.close();
    System.out.println("\nIndexer: close took " + (System.currentTimeMillis() - tCloseStart) + " msec");
    dir.close();
    final long tFinal = System.currentTimeMillis();
    System.out.println("\nIndexer: finished (" + (tFinal-t0) + " msec)");
    System.out.println("\nIndexer: net bytes indexed " + threads.getBytesIndexed());
    System.out.println("\nIndexer: " + (threads.getBytesIndexed()/1024./1024./1024./((tFinal-t0)/3600000.)) + " GB/hour plain text");
  }
}
