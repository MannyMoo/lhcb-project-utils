# Utilities for working with the LCG. 

function prep_grid_cert() {
    if [ ! -d $HOME/.globus ]
	then
	mkdir $HOME/.globus ;
    fi
    if [ -a $HOME/.globus/usercert.pem ]
	then 
	if [ -a $HOME/.globus/usercert_prev.pem ]
	    then 
	    rm $HOME/.globus/usercert_prev.pem ;
	fi
	chmod 664 $HOME/.globus/usercert.pem ;
	mv $HOME/.globus/usercert.pem $HOME/.globus/usercert_prev.pem ;
    fi
    openssl pkcs12 -clcerts -nokeys -in $1 -out $HOME/.globus/usercert.pem ;  #this creates the certificate
    if [ -a $HOME/.globus/userkey.pem ]
	then 
	if [ -a $HOME/.globus/userkey_prev.pem ]
	    then 
	    rm $HOME/.globus/userkey_prev.pem ;
	fi
	chmod 664 $HOME/.globus/userkey.pem ;
	mv $HOME/.globus/userkey.pem $HOME/.globus/userkey_prev.pem ;
    fi
    openssl pkcs12 -nocerts -in $1 -out $HOME/.globus/userkey.pem ;  #this creates your private key
    mv $1 $HOME/.globus/ ;
    chmod 400 $HOME/.globus/userkey.pem ;
    chmod 444 $HOME/.globus/usercert.pem ;
}
