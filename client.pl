#!/usr/bin/env/ perl

#{}
#<>
my $nomUtilisateur = "";
my $motDePasse = "";

sub VerificationMotDePasse{
  my $verificationInput = <STDIN>;
  if ($verificationInput =~ /\w{2,}/){
    $motDePasse = $verificationInput;
  }
  else{
    print "Veuillez entrer un mot de passe contenant\nau moins un chiffre, une lettre et non vide :\n";
    VerificationMotDePasse();
  }
}

sub Connection{
  print "Menu de connection\n1. Se connecter\n2. Créer un compte\n";
  my $input = <STDIN>;

  #Connection
  if ($input == "1"){
    print "Nom d'utilisateur :\n";
    $nomUtilisateur = <STDIN>;
    print "Mot de passe :\n";
    $motDePasse = <STDIN>;
  }
  
  #Créer un compte
  if ($input == "2"){
    print "Entrez un nom d'utilisateur :\n";
    $nomUtilisateur = <STDIN>;
    print "Entrez un mot de passe (Doit au moins contenir\nun chiffre et une lettre) :\n";
    VerificationMotDePasse();
  }
}

sub MainMenu{
  print "Menu principal\n1. Envoi de courriels\n2. Consultation du courriels\n3. Satistiques\n4. Quitter\n";
  $input = <STDIN>;
  if ($input == "1"){
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

Connection();
MainMenu();
