package it.unipd.dei.ims.lucene.clef.parser;

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
import org.apache.lucene.benchmark.quality.QualityQuery;
import org.apache.lucene.benchmark.quality.QualityQueryParser;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.queryparser.classic.QueryParserBase;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Query;

/**
 * Parser for {@link QualityQuery}.
 */
public class ClefQQParser implements QualityQueryParser {

    private String fieldToSearch;
    private String qqFields[];
    private String language;
    private String stemmer;
    private CharArraySet stopset;

    ThreadLocal<QueryParser> queryParser = new ThreadLocal<>();

    public ClefQQParser(
            String qqFields[],
            String fieldToSearch,
            String language,
            String stemmer,
            CharArraySet stopset) {
        this.qqFields = qqFields;
        this.fieldToSearch = fieldToSearch;
        this.language=language;
        this.stemmer=stemmer;
        this.stopset=stopset;
    }

    public ClefQQParser(
            String qqField,
            String fieldToSearch,
            String language,
            String stemmer,
            CharArraySet stopset
    ) {
        this(new String[] { qqField }, fieldToSearch, language, stemmer, stopset);
    }

    @Override
    public Query parse(QualityQuery qq) throws ParseException {
        QueryParser qp = queryParser.get();
        if (qp==null) {
            Analyzer analyzer = AnalyzerFactory.createAnalyzer(
                    language,
                    stemmer,
                    stopset
            );
            qp = new QueryParser(fieldToSearch, analyzer);
            queryParser.set(qp);
        }
        BooleanQuery bq = new BooleanQuery();
        for (int i = 0; i < qqFields.length; i++)
            bq.add(qp.parse(QueryParserBase.escape(qq.getValue(qqFields[i]))), BooleanClause.Occur.SHOULD);

        return bq;
    }
}
