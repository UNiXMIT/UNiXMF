# Eclipse German Language Support

- **Format settings** of the system set to German (Germany) or German (Austria). Note that Format Settings is not necessarily set to German when you set the region (country) to German. You will need to set the Format settings explicitly if they are not set to German.  

![1](images/osLangGer.png)

- **MF_INSTALL_DE_LANG_PACK YES** is set as an environment variable for the system (not for the user!) with value Yes (the case of the value does not matter).   

![2](images/envGer.png)

To enable German in Eclipse, either the display language of the system should be set to German or Eclipse should be started with '-nl de' command line argument (or added in eclipse.ini).  