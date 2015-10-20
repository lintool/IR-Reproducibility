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

import it.unipd.dei.ims.lucene.clef.applications.BatchRetrieval;
import it.unipd.dei.ims.lucene.clef.applications.BuildIndex;

/**
 * Functionalities for CLEF Test collections indexing and batch retrieval.
 */
public class App {

    public static void main(String [] args){

        if (args.length==1){

            String option = args[0].toLowerCase();
            switch (option){
                case "-i" :
                    BuildIndex.main(args);
                    break;
                case "-r" :
                    BatchRetrieval.main(args);
                    break;
                default:
                    System.out.println("Supported options:");
                    printHelp();
            }

        } else {

            System.out.println("One of the following option should be used:");
            printHelp();

        }

    }

    private static void printHelp(){

        System.out.println("-h for this help");
        System.out.println("-i for indexing");
        System.out.println("-r for batch retrieval");
    }



}
