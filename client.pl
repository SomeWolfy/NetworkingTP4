#!/usr/bin/env/ perl

#{}
#<>
my $nomUtilisateur = "";
my $motDePasse = "";
my $inputServer = "";

sub VerificationMotDePasse{
  $motDePasse = <STDIN>;
  if !($motDePasse =~ /\S+/ && $motDePasse =~ /\d+/ && $motDePasse =~ /\D+/){
    print "Veuillez entrer un mot de passe contenant\nau moins un chiffre, une lettre et non vide : ";
    VerificationMotDePasse();
  }
}

sub CommunicationServer {
  while ($inputServer == "") 
    client->send(@_[0]);
    $client->recv($inputServer, 2048);
  }
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
  print "Nom d'utilisateur :";
  $nomUtilisateur = <STDIN>;
  print "Mot de passe :";
  $motDePasse = <STDIN>;
  if (CommunicationServer($dataList) == "0"){
    print "Le nom d'utilisateur et/ou mot de passe n'existent pas.\n"
    Connection();
  }
}

sub CreateAccount {
  print "Entrez un nom d'utilisateur :";
  $nomUtilisateur = <STDIN>;
  print "Entrez un mot de passe (Doit au moins contenir\nun chiffre et une lettre) :";
  VerificationMotDePasse();
  if (CommunicationServer($dataList) == "0"){
    print "Le nom d'utilisateur et/ou mot de passe est déjà en utilisation.\nVeuillez en choisir d'autres."
    CreateAccount();
  }
}

sub ConnectionMenu {
#Tentative de connection au serveur
  my $client = IO::Socket::INET->new(Proto => "tcp",
            PeerAddr => $destinationIp,
            PeerPort => $port)
  or ErrorManager("Impossible de se connecter sur le port $port à l'adresse $destionationIp");


  print "Menu de connection\n1. Se connecter\n2. Créer un compte";
  my $input = <STDIN>;
  my $dataList = ($input,$nomUtilisateur, $motDePasse);

  #Connection
  if ($input == "1"){
    Connection();
    MainMenu();
  }  
  
  #Créer un compte
  else if ($input == "2"){
    CreateAccount();
    ConnectionMenu();
  }
}

sub MainMenu {
  print "Menu principale\n1. Envoi de courriels\n2. Consultation des courriels\n3. Statistiques\n4. Quitter\n"
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
    my $emailInfos = ("3",$destAddr,$ccAddr,$subject,$body); 
    CommunicationServer($emailInfos);
    MainMenu();
  }

  if ($input == "2"){
    MainMenu();
  }

  if ($input == "3"){
    MainMenu();
  }

  if ($input == "4"){
  }
}  






