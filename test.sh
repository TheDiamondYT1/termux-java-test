#!/data/data/com.termux/files/usr/bin/bash

JAVA="yes"
MAVEN="yes"
CERT="yes"

DIR=$HOME/test

echo "--------------------------------------"
echo " Termux Java Tests                    "
echo "--------------------------------------"
echo 

mkdir $DIR &>/dev/null

echo "Checking test dependencies..."
# Java
echo -n " java..."
type java &>/dev/null && echo -e "installed" || echo -e "not installed" && JAVA="no"

# Maven
echo -n " maven..."
type mvn &>/dev/null && echo -e "installed" || echo -e "not installed" && MAVEN="no"

# Java Certificates
echo -n " ca-certificates-java..."
CERT=$(dpkg-query -W --showformat="${Status}\n" ca-certificates-java | grep "install ok installed") &>/dev/null

if [ "$CERT" == "" ]; then
    echo -e "not installed"
    CERT="no"
else
    echo -e "installed"
fi

echo 

# Java Certificates
if [ $CERT == "no" ]; then
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
    curl http://mirrors.ukfast.co.uk/sites/ftp.apache.org/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz > $DIR/maven-3.5.0.tar.gz &>/dev/null
    if [ ! -f "$DIR/maven-3.5.0.tar.gz" ]; then
        echo -e "failed"
    else 
        echo -e "done"
    fi
    
    echo -n " Setting up..."
    tar -zxf $DIR/maven-3.5.0.tar.gz &>/dev/null
    export PATH=$PATH:$DIR/maven-3.5.0/bin
    termux-fix-shebang $DIR/maven-3.5.0/bin/mvn
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

if [ ! $((java -jar "$DIR/helloworld/Main.jar" | grep "Hello world") &>/dev/null) ]; then
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

echo "Now for this one i am going to enable output...this could get spammy."
sleep 5

cd $DIR/voxelwind && mvn package

echo

echo "Done. This took a long time for me to write :D"
