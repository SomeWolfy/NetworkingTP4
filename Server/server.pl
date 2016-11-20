#!/usr/bin/env perl

use Getopt::Long;
use IO::Socket;
use File::Find;

sub Connection {
  $serveur = IO::Socket::INET->new( Proto => "tcp",
                                    LocalPort => 1234,
                                    Listen => SOMAXCONN,
                                    Reuse => 1)
  or ErrorManager("Impossible de se connecter sur le port $port en localhost");

  #ValidUser("test");
  #ValidPassword("test", "allo");
  #CreateUser("Userfhdj Name", "Password")
  #SendEmail("test\@reseauglo.ca", "adresse copie", "un sujet", "un message");
  #ListEmail("test");
  CheckEmail("un sujet", "test");
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
    my $destination = @_[0];
    my $destinationCC = @_[1];
    my $subject = @_[2];
    my $message = @_[3];

    #Permet d'enregistrer les emails interne si l'adresse de destination contient @reseauglo.ca
    if ($destination =~ s/@reseauglo\.ca//g) {
      my $emailUsername = substr($destination, 0, index($destination, "@"));
      if (-d $emailUsername) {
        open(my $fh, ">>", $emailUsername."/$subject")
            or ErrorManager("Impossible d'insérer le message dans le dossier de l'utilisateur");

        say $fh "De : $destination\n";
        say $fh "Sujet : $subject\n";
        say $fh $message;

        close($fh);

      }
      else {
        mkdir("DESTERREUR", 0755) unless(-d "DESTERREUR");
        open(my $fh, ">>", "DESTERREUR/$subject")
            or ErrorManager("Impossible d'insérer le message dans le dossier DESTERREUR");

        say $fh "De : $destination\n";
        say $fh "Sujet : $subject\n";
        say $fh $message;

        close($fh);

      }

    }
    else {
      #Faudrait envoyer en utilisant smtp
    }

  return 1;
}

#Au lieu d'envoyer le un liste numeroter je vais envoyer une liste
#les numero seront l'index + 1
sub ListEmail {
  my $user = @_[0];

  opendir (DIR, $user) or ErrorManager("Impossible d'ouvrir le dossier : $user");
  while (my $file = readdir(DIR)) {
    #On ne veut pas afficher le fichier config ni les dossiers
    next if ($file =~ m/config\.txt|^\./);
    print "$file\n";

  }

  close(DIR);
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
