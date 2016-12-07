#!/usr/bin/env/ perl

#{}
#<>
#

use IO::Socket::INET;

my $nomUtilisateur = "";
my $motDePasse = "";
my $inputServer = "";
my $destionationIp = "localhost";
my $port = "1234";
my $client = IO::Socket::INET->new(Proto => "tcp", PeerAddr => "localhost", PeerPort => 1234) or die;
my $dataList = ();

sub VerificationMotDePasse{
  $motDePasse = <STDIN>;
  if ($motDePasse !=~ /\S+/ && $motDePasse !=~ /\d+/ && $motDePasse !=~ /\D+/){
    print "Veuillez entrer un mot de passe contenant\nau moins un chiffre, une lettre et non vide : ";
    VerificationMotDePasse();
  }

  return $motDePasse;
}

sub CommunicationServer {
  my $array = join(';', @_);
  print "result test : $array\n";
  $array =~ s/\r|\n|\r\n//g;
  $client->send("$array\n");
  $client->recv($inputServer, 2048);
  print "$inputServer\n";
  return $inputServer;
}

#Gère les messages d'erreur et les enregistre dans le Errorlog
sub ErrorManager {
  my $filename = "Error.log";
  open(my $fh, ">>", $filename) or die "Impossible d’ouvrir
  Error.log en écriture : $!";

  my $errorMessage = @_[0];

  say $fh "\nErreur : " .$errorMessage." en date et heure du ".localtime();

  close($fh);
}

sub Connection {
  @dataList = ();
  push @dataList, "1";
  print "Nom d'utilisateur :";
  $nomUtilisateur = <STDIN>;
  push @dataList, $nomUtilisateur;
  print "Mot de passe :";
  $motDePasse = <STDIN>;
  push @dataList, $motDePasse;
  if (CommunicationServer(@dataList) == "0"){
    print "Le nom d'utilisateur et/ou mot de passe n'existent pas.\n";
    Connection();
  }
}

sub CreateAccount {
  @dataList = ();
  push @dataList, "2";
  print "Entrez un nom d'utilisateur :";
  $nomUtilisateur = <STDIN>;
  push @dataList, $nomUtilisateur;
  print "Entrez un mot de passe (Doit au moins contenir\nun chiffre et une lettre) :";
  my $motDePasse = VerificationMotDePasse();
  if (CommunicationServer(@dataList) == "0"){
    print "Le nom d'utilisateur et/ou mot de passe est déjà en utilisation.\nVeuillez en choisir d'autres.";
    CreateAccount();
  }
}

sub ConnectionMenu {
#Tentative de connection au serveur
    #$client = IO::Socket::INET->new(Proto => "tcp", PeerAddr => 'localhost', PeerPort => 1234) or die;
  print "Menu de connection\n1. Se connecter\n2. Créer un compte\n";
  my $input = <STDIN>;


  #Connection
  if ($input == "1"){
    Connection();
    MainMenu();
  }

  #Créer un compte
  elsif ($input == "2"){
    CreateAccount();
    ConnectionMenu();
  }
}

sub MainMenu {
  print "Menu principale\n1. Envoi de courriels\n2. Consultation des courriels\n3. Statistiques\n4. Quitter\n";
  my $input = <STDIN>;

  if ($input == "1"){
    print "Entrez l'adresse de destination : ";
    my $destAddr = <STDIN>;
    print "Entrez l'adresse de copie conforme : ";
    my $ccAddr = <STDIN>;
    print "Entrez le sujet de votre email : ";
    my $subject = <STDIN>;
    print "Entrez le corps de votre email : ";
    my $body = <STDIN>;
    my @emailInfos = ("3",$destAddr,$ccAddr,$subject,$body);
    CommunicationServer(@emailInfos);
    MainMenu();
  }

  if ($input == "2"){
    my @emailList = split /;/, CommunicationServer("4");
    print "size array : $#emailList\n";
	for(my $i = 0; $i < $#emailList; $i++){
	  print "$i $emailList[$i]\n";
	}
	print "Entrez le numéro du email que vous voulez lire : ";
	$input = <STDIN>;
	print CommunicationServer($input);
	print "Entrez nimporte quoi pour revenir au menu principal\n";
	$input = "";
	while ($input == ""){
	   $input = <STDIN>;
	}
    MainMenu();
  }

  if ($input == "3"){
    my @stats = split /;/, CommunicationServer("5");
	print "Nombre de messages dans votre dossier : $stats[0]\nGrandeur totale de votre dossier : $stats[1] bytes\nMessages dans votre dossier :\n";
	foreach my $i (2 .. $#stats) {
      print "$stats[$i]\n";
    }

	print "Entrez nimporte quoi pour revenir au menu principal\n";
	$input = "";
	while ($input == ""){
	   $input = <STDIN>;
	}
    MainMenu();
  }

  if ($input == "4"){
    CommunicationServer("6");
    $client->close();
  }
}

ConnectionMenu();
