#!/usr/bin/env perl

use Getopt::Long;
use IO::Socket;
use File::Find;
use MIME::Lite;

sub Connection {
  my $serveur = IO::Socket::INET->new( Proto => "tcp",
                                    LocalPort => 1234,
                                    Listen => SOMAXCONN,
                                    Reuse => 1)
  or ErrorManager("Impossible de se connecter sur le port $port en localhost");
  while (my $connection = $serveur->accept())
  {
    my $i = 0;
    print "Connection $i au serveur\n";

    $serveur->recv($inputServer, 2048);
    printf $inputServer;
  }
  #ValidUser("test");
  #ValidPassword("test", "allo");
  #CreateUser("Userfhdj Name", "Password")
  SendEmail("test\@allo.ca", "qwerty\@reseauglo.ca", "adresse copie", "un sujet", "un message");

  #Avec un courriel qui est pas rapport avec reseauglo.ca
  #SendEmail("test\@allo.ca", "mouche2332\@hotmail.com", "adresse copie", "un sujet", "un message");

  my @testList = ListEmail("test");
  say $testList[0];
  #CheckEmail("un sujet", "test");
  #SendStats("test");
}

#Verifie si l'utilisateur existe vraiment en regardant s'il a un dossier a son nom
sub ValidUser {
  my $user =  @_[0];

  if (-d $user) {
    return 1;
  }
  else {
    return 0;
  }
}

#Verifie que le mot de passe passer en paramatere est bien celui a la premiere
#ligne du fichier config.txt du dossier de l'utilisateur
sub ValidPassword {
  my $user = @_[0];
  my $password = @_[1];

  open(my $fh, '<:encoding(UTF-8)', $user."/config.txt")
  or ErrorManager("Impossible d'ouvrir le fichier : $user./config.txt");

  while (my $row = <$fh>) {
    chomp $row;
    if($row eq $password) {
      close($fh);
      return 1;
    }
    else {
      close($fh);
      return 0;
    }
  }
}

#Permet la creation d'un usager. Verifie si l'usager n'existe pas avant de le creer
sub CreateUser {
  my $user = @_[0];
  my $password = @_[1];

  if (ValidUser($user) == 0) {
    mkdir($user, 0755);
    open(my $fh, ">>", $user."/config.txt")
    or ErrorManager("Impossible d’ouvrir le fichier config.txt");

    say $fh $password;
    close($fh);
    return 1;
  }
  else {
    return 0;
  }
}


sub SendEmail {
    my $currentUser = @_[0];
    my $destination = @_[1];
    my $destinationCC = @_[2];
    my $subject = @_[3];
    my $message = @_[4];

    #Permet d'enregistrer les emails interne si l'adresse de destination contient @reseauglo.ca
    if ($destination =~ /\@reseauglo\.ca/) {
      my $emailUsername = substr($destination, 0, index($destination, "@"));
      if (-d $emailUsername) {
        open(my $fh, ">>", $emailUsername."/$subject")
            or ErrorManager("Impossible d'insérer le message dans le dossier de l'utilisateur");

        say $fh "De : $destination\n";
        say $fh "Sujet : $subject\n";
        say $fh $message;

        close($fh);

        return 1;

      }
      else {
        mkdir("DESTERREUR", 0755) unless(-d "DESTERREUR");
        open(my $fh, ">>", "DESTERREUR/$subject")
            or ErrorManager("Impossible d'insérer le message dans le dossier DESTERREUR");

        say $fh "De : $destination\n";
        say $fh "Sujet : $subject\n";
        say $fh $message;

        close($fh);

        return 1;
      }

    }
    else {
      $msg = MIME::Lite->new(
        From => $currentUser,
        To => $destination,
        Cc => $destination,
        Subject => $subject,
        Data => $message
      );

      $msg->send('smtp', "smtp.ulaval.ca", Timeout=>60);
      return 1;
    }

  return 0;
}

#Au lieu d'envoyer une liste numeroter je vais envoyer une liste
#les numero seront l'index + 1
sub ListEmail {
  my $user = @_[0];

  my @subjectList;
  opendir (DIR, $user) or ErrorManager("Impossible d'ouvrir le dossier : $user");
  while (my $file = readdir(DIR)) {
    #On ne veut pas afficher le fichier config ni les dossiers
    next if ($file =~ m/config\.txt|^\./);
    printf $file."\n";
    push @subjectList, "$file";

  }

  close(DIR);

  return $subjectList;
}

#Devrait recevoir le sujet du courrier et non le numero
sub CheckEmail {
  my $emailSubject = @_[0];
  my $user = @_[1];
  my $message = "";
  open(my $fh, '<:encoding(UTF-8)', "$user/$emailSubject")
  or ErrorManager("Impossible d'ouvrir le fichier : $user/$emailSubject");

  while (my $row = <$fh>) {
    chomp $row;
    $message .= "$row\n";
  }

  close($fh);

  printf $message;
}

sub SendStats {
  my $user = @_[0];
  my $total;
  my $emailsNb = 0;

  find(sub { $total += -s if -f }, $user);

  printf "$total bytes\n";


  opendir (DIR, $user) or ErrorManager("Impossible d'ouvrir le dossier : $user");
  while (my $file = readdir(DIR)) {
    #On ne veut pas afficher le fichier config ni les dossiers
    next if ($file =~ m/config\.txt|^\./);
    print "$file\n";
    $emailsNb++;
  }
  close(DIR);

  printf $emailsNb;

}

sub ErrorManager {
  my $filename = "Error.log";
  open(my $fh, ">>", $filename);

  my $errorMessage = @_[0];

  say $fh "\nErreur : " .$errorMessage." en date et heure du ".localtime();

  close($fh);
}

Connection();
