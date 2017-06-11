#!/data/data/com.termux/files/usr/bin/bash

JAVA="yes"
MAVEN="yes"
CERT="yes"

DIR=$HOME/test

echo   "-------------------------------------"
printf "%b\n" "\033[32m Termux Java Tests\033[39m"
echo   "-------------------------------------"
echo 

rm -rf $DIR &>/dev/null
mkdir $DIR &>/dev/null

echo "Checking device details..."
echo " Arch: $(getprop ro.product.cpu.abi)"

echo

echo "Checking test dependencies..."
# Java
echo -n " java..."
type java &>/dev/null && echo -e "installed" || echo -e "not installed" && JAVA="no"

# Maven
echo -n " maven..."
type mvn &>/dev/null && echo -e "installed" || echo -e "not installed" && MAVEN="no"

# Java Certificates
echo -n " ca-certificates-java..."
CERT=$((apt list ca-certificates-java | grep "installed") 2>/dev/null)

if [ "$CERT" == "" ]; then
    echo -e "not installed"
    CERT="no"
else
    echo -e "installed"
fi

echo 

# Java Certificates
if [ "$CERT" == "no" ]; then
    echo "Java CA Certificates"
    
    echo -n " Installing..."
    apt install ca-certificates-java -f &>/dev/null
    echo -e "done"
fi

echo

#if [ $JAVA == "no" ]; then 
#    echo "Java v9-internal"
#
#    echo -n " Downloading..."  
#fi

# Maven
if [ "$MAVEN" == "no" ]; then
    echo "Maven v3.5.0"
    
    echo -n " Downloading..."
    cd $DIR && curl -Ls http://mirrors.ukfast.co.uk/sites/ftp.apache.org/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz > maven-3.5.0-bin.tar.gz
    if [ ! -f "$DIR/maven-3.5.0-bin.tar.gz" ]; then
        echo -e "failed"
    else 
        echo -e "done"
    fi
    
    echo -n " Setting up..."
    cd $DIR && tar -zxf maven-3.5.0-bin.tar.gz 
    export PATH=$PATH:$DIR/apache-maven-3.5.0/bin
    termux-fix-shebang $DIR/apache-maven-3.5.0/bin/mvn
    echo -e "done"
fi

echo
echo "------------------------------"
echo " Starting tests...            "
echo " These could take a while     "
echo "------------------------------"
echo 

sleep 2

# Java Hello World Test
echo -n "Java Hello World Test..."
cd $DIR && $(git clone https://github.com/macagua/example.java.helloworld helloworld &>/dev/null)
cd $DIR/helloworld && $(javac HelloWorld/Main.java &>/dev/null)
cd $DIR/helloworld && $(jar cfme Main.jar Manifest.txt HelloWorld.Main HelloWorld/Main.class &>/dev/null)

if [ ! -f $DIR/helloworld/Main.jar ]; then
    echo -e "fail"
else
    echo -e "success"
fi

sleep 1

# Maven Project Generate Test
echo -n "Maven Project Generate Test..."
cd $DIR && $(mvn archetype:generate -DgroupId=com.maven.test.generate -DartifactId=MavenGenerateTest -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false &>/dev/null)

if [ ! -f "$DIR/MavenGenerateTest/pom.xml" ]; then
    echo -e "fail"
else 
    echo -e "success"
fi

# Minecraft Server Lombok Test
echo "Minecraft Server Lombok Test..."
cd $DIR && $(git clone https://github.com/voxelwind/voxelwind &>/dev/null)
echo -e " Enabling error output for this one..."

sleep 3

cd $DIR/voxelwind && printf "%b\n" "$(mvn package | grep 'ERROR*')"

echo

echo "Done. This took a long time for me to write :D"
