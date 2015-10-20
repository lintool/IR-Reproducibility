Method Description:
  xiao jie liu(James Liu), the student of Professor Jian-Yun Nie, submits the CLEF baseline experiments results. James used Lemur/Indri to be 
the basic retrieval platform and used language model with Dirichlet Smoothing(mu=2000) for the retrieval model. James dealed with 12 languages
for the topics and corpora. They are Hungarian(hu),Italian(it),Dutch(nl),Portuguese(pt),Russian(ru),Swedish(sv),German(de),Spanish(es),Finnish(fi),
French(fr),Bulgarian(bg) and Persian(fa).
  James Liu pre-processed the topics files and Corpora by removing the stopwords and stemming the contents. Stopwords list files are provided
by Maria Maistro (maistro@dei.unipd.it), you can download from https://github.com/mmaistro/IR-Reproducibility/tree/mmaistro. The stemming methods
used are from Professfor Jacques.Savoy (Jacques.Savoy@unine.ch)(http://members.unine.ch/jacques.savoy/clef/index.html) for language Bulgarian;
from Jonsafari (https://www.ling.ohio-state.edu/~jonsafari/persian_nlp.html) for language Persian; from Snowball (http://snowball.tartarus.org/)
for other languages (Hungarian,Italian,Dutch,Portuguese,Russian,Swedish,German,Spanish,Finnish and French).
  In the final result, for each topic, there are 1000 documents returned. And the format is Trec standard format. 
 
