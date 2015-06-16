EC2 Setup
=========

For the Gov2 experiments, we are currently running the `r3.4xlarge` instance, with 16 vCPUs and 122 GiB memory, Ubuntu Server 14.04 LTS (HVM).

After logging in, the instance is first prepped by installing common missing packages:

```
sudo apt-add-repository -y ppa:webupd8team/java
sudo apt-get -y update
sudo apt-get -y install oracle-java8-installer
sudo apt-get -y install emacs24
sudo apt-get -y install make
sudo apt-get -y install gcc
sudo apt-get -y install g++
sudo apt-get -y install git
sudo apt-get -y install mercurial
```

After that, the collection is mounted:

```
sudo mkdir /media/Gov2
sudo mount /dev/xvdf /media/Gov2
```

The collection is held on a [standard](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html) EBS volume (i.e., magnetic). According to Amazon, this volume type will deliver 40-90 MiB/s maximum throughput. This should be sufficient for IR engines, but if any system is bumping up against this limit, we'll certainly revisit.

So, you'll see:

```
$ ls /media/Gov2/data/
GX000  GX011  GX022  GX033  GX044  GX055  GX066  GX077  GX088  GX099  GX110  GX121  GX132  GX143  GX154  GX165  GX176  GX187  GX198  GX209  GX220  GX231  GX242  GX253  GX264
GX001  GX012  GX023  GX034  GX045  GX056  GX067  GX078  GX089  GX100  GX111  GX122  GX133  GX144  GX155  GX166  GX177  GX188  GX199  GX210  GX221  GX232  GX243  GX254  GX265
GX002  GX013  GX024  GX035  GX046  GX057  GX068  GX079  GX090  GX101  GX112  GX123  GX134  GX145  GX156  GX167  GX178  GX189  GX200  GX211  GX222  GX233  GX244  GX255  GX266
GX003  GX014  GX025  GX036  GX047  GX058  GX069  GX080  GX091  GX102  GX113  GX124  GX135  GX146  GX157  GX168  GX179  GX190  GX201  GX212  GX223  GX234  GX245  GX256  GX267
GX004  GX015  GX026  GX037  GX048  GX059  GX070  GX081  GX092  GX103  GX114  GX125  GX136  GX147  GX158  GX169  GX180  GX191  GX202  GX213  GX224  GX235  GX246  GX257  GX268
GX005  GX016  GX027  GX038  GX049  GX060  GX071  GX082  GX093  GX104  GX115  GX126  GX137  GX148  GX159  GX170  GX181  GX192  GX203  GX214  GX225  GX236  GX247  GX258  GX269
GX006  GX017  GX028  GX039  GX050  GX061  GX072  GX083  GX094  GX105  GX116  GX127  GX138  GX149  GX160  GX171  GX182  GX193  GX204  GX215  GX226  GX237  GX248  GX259  GX270
GX007  GX018  GX029  GX040  GX051  GX062  GX073  GX084  GX095  GX106  GX117  GX128  GX139  GX150  GX161  GX172  GX183  GX194  GX205  GX216  GX227  GX238  GX249  GX260  GX271
GX008  GX019  GX030  GX041  GX052  GX063  GX074  GX085  GX096  GX107  GX118  GX129  GX140  GX151  GX162  GX173  GX184  GX195  GX206  GX217  GX228  GX239  GX250  GX261  GX272
GX009  GX020  GX031  GX042  GX053  GX064  GX075  GX086  GX097  GX108  GX119  GX130  GX141  GX152  GX163  GX174  GX185  GX196  GX207  GX218  GX229  GX240  GX251  GX262
GX010  GX021  GX032  GX043  GX054  GX065  GX076  GX087  GX098  GX109  GX120  GX131  GX142  GX153  GX164  GX175  GX186  GX197  GX208  GX219  GX230  GX241  GX252  GX263
```

Then, the workspace is mounted:

```
sudo mkdir /media/workspace
sudo mount /dev/xvdg /media/workspace
```

The workspace will serve as the location for holding code, indexes, etc. It is a general purpose SSD EBS volume. This is where the IR-Reproducibility repo should reside.

