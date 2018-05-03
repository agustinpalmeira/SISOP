#perl -v
MIN_PERL_VERSION=5
PERL_VERSION=$(perl -e 'print $];')
if [ "$PERL_VERSION" -ge "$MIN_PERL_VERSION" ]
then
  echo $PERL_VERSION
fi 
