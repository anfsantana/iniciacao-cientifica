#!/usr/bin/perl
# Constantes
my $INDEX_NOUN = "index.noun";
my $DATA_NOUN = "data.noun";
#my $DIRETORIO = "D:/Projetos/WordNet/WordNet/dict/";
my $DIRETORIO = "C:/WordNet/dict/";
my $DISCOVER_DATA = "discover.data";
my $MEU_DISCOVER_DATA = "meuDiscover.data";
my $MEU_DISCOVER_NAMES = "meuDiscover.names";
my $DISCOVER_NAMES = "discover.names";
my $DIRETORIO_DISCOVER = "C:/WordNet/";
my $LOG_NAMES = "Log/logNames.txt";
my $MINIMOSINONIMOS;
# perl trim function - remove leading and trailing whitespace
use strict;
use Informacao;
use Time::HiRes qw(usleep);
# Remover espaços antes e depois de uma string
sub trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

sub extrairPalavras($){
   my $linha  = shift;
   my $nome;
   ($nome) = $linha =~ /(([a-z]){1}\S.*\b\s(@))/ ;
   ($linha) = $nome =~ /(([a-z]){1}\S.*.([a-z]){1}\b)/; 
                      
    return $linha;                   
}

sub extrairNomes{
   my $new = $_[0];
   my $palavra;
   ($palavra) = $new =~ /^(\"[a-zA-z]+\")/;
   ($new) = $palavra =~ /([a-zA-z]+)/;
   
   return ($new);
   
}

sub extrairDigitoByColchetes{
   my $new = $_[0];
   my $digito;
   ($digito) = $new =~ /(\b\d*[\d])/;
   
   
   return ($digito);
   
}

sub obterMatrizNames(){
      $|= 1;
      
      my @discoverNames;
      my $num = 0;
      open(DISCOVERNAMES, $DIRETORIO_DISCOVER.$DISCOVER_NAMES) or die  "Couldn't open file "." ".$DISCOVER_NAMES,", $!";		
      print "- Lendo arquivo 'discover.names' \n";
      while ( <DISCOVERNAMES> ){         
         chomp;
         push @discoverNames, [ split /,/ ];
         $num = $num + 1;         
         print "  $num  - ".extrairNomes($_)."                                ";
         usleep(100000);
         print ("\b" x (length("  $num  - ".extrairNomes($_)."                                ")));
      }
      print "\n";
      $MINIMOSINONIMOS = 10; # Ideia: Colocar um calculo para escolhe a quantidade adequada mínima para a lista de sinônimos
   return @discoverNames;
   
}

sub obterMatrizData(){
   my @discoverData;
   $|=1;
   my $num = 0;
   open(DISCOVERDATA, $DIRETORIO_DISCOVER.$DISCOVER_DATA) or die  "Couldn't open file "." ". $DISCOVER_DATA,", $!";		
   print "- Lendo arquivo 'discover.data' \n";
   while ( <DISCOVERDATA> ){
       $num = $num + 1;
       print "[     $num     ]";
       usleep(100000);
       print ("\b" x (length("[     $num     ]")));
       chomp;
       push @discoverData, [ split /,/ ];
   }   
   print "\n";
   return @discoverData;
   
}

# Função para obter um hash de sinônimos.
# - parâmetro: palavra para busca.
sub buscarSinonimos($){
	my $word = trim($_[0]);
	my $number;	
	my $linha;
	my $number;
	my $nome;
	my $id; 
	my $linha2;
	my %data;
	my @palavras;
	 
	 #Ler o arquivo index.noun
	open(INDEX, $DIRETORIO.$INDEX_NOUN) or die  "Couldn't open file "." ". $INDEX_NOUN,", $!";		
	
	while(<INDEX>){		  
	   if(/^$word.*?\b/){# Pesquisa a palavra informada, baseado em like no banco de dados como: like bcd% → ^bcd.*?$
		$linha = $_;				
		($number) = $linha =~ /\s([0-9]{8}\s.*)/;	#Obtém os ids da linha referente aos sinônimos.	
		last;
	   }
	}
	close(INDEX);
	 
	 #Se não encontrou nenhum número, quer dizer que não encontrou palavra.
	 #Retorna o hash %data vazio.
	if(length($number) <= 0){
	   # print "Sem resultados. \n";	   
	   return %data;
	}
	       
	
	my @ids = split(" ",trim($number)); #Pega os ids na linha do arquivo.	
        my @sorted_ids = sort { $a <=> $b } @ids; #Ordena os ids.
	foreach (@sorted_ids){ 
                 $id = $_;
                 open(DATA, $DIRETORIO.$DATA_NOUN) or die  "Couldn't open file "." ". $DATA_NOUN,", $!"; #Ler o arquivo data.noun		
                 while(<DATA>){		  
                     if(/^$id /){#Pega o ID da lista ordenada e pesquisa as palavras que são relacionadas ao mesmo.
                       $linha2 = trim($_);                                            
                       @palavras = split(/[0-9]/, extrairPalavras($linha2)); # Obtém as palavras da linha do arquivo
                       foreach(@palavras){ # Adiciona as palavras encontradas ao hash $data
                          my $w = trim($_); 
                          my $onlyWord;
                         ($onlyWord) = $w =~ /(^[a-zA-z]+$)/;                          
                         
                          if(length($onlyWord) > 1){
                              $data{$w} = $w;    # Exemplo: key = student, value = student.                          
                           }
                       }                                            	
                       last;
                  }				 			
               }
               close(DATA);  
	}
                
       

         return %data;
      
}

sub percorrerArquivoData{
   
   my @discoverData;
   my $row;
   my $column;
   
   open(DISCOVERDATA, $DIRETORIO_DISCOVER.$DISCOVER_DATA) or die  "Couldn't open file "." ". $DISCOVER_DATA,", $!";		
   while ( <DISCOVERDATA> ){
     chomp;
     push @discoverData, [ split /,/ ];
   }
   
   foreach $row (0..@discoverData-1){    
      foreach $column (0..@{$discoverData[$row]}-1) {
         print "Element [$row][$column] = $discoverData[$row][$column] \n";          
      }
   }
   
   # Exemplo :
   # $discoverData[0][6] = 30;
   # $linha = join(',', @{$discoverData[$row]}); 
   # print "$linha \n"
}



sub buscaRecursiva{
  my $k = 0;
  my $i = 0;
  my %newHash;
  my %retorno;
  my %data;
  my $key;
  %data = @_;
  # $|=1;
   $k += scalar keys %data;

   if($k == 0 or $k >= $MINIMOSINONIMOS){
      return %data;
   }
   
    # print  " \n (LOG: Tamanho do data----> $k)\n\n";
   foreach $key (sort keys %data){
         # print ".";
         # usleep(100000);
        if(length(trim($key)) > 2){
           # print  "  (LOG: PALAVRA USADA PARA BUSCA: ($key)) \n"; 
	  %retorno =  buscarSinonimos($key);
          @data{keys %retorno} = values %retorno;
      }
   }           
 
   $i += scalar keys %data; 
    # print  " \n (LOG: Tamanho da NOVA lista de sinonimos: $i)\n    Tamanho da ANTIGA lista de sinonimos: $k \n\n";
    # print  " -------------------------------------------------------------------- \n";

   if($i == $k or $i == 0 ){      
      return %data; #Exemplo shopping
   }  
   return buscaRecursiva(%data); 
   
}

sub mapearArquivoNomes{
       $|=1;
       my @discoverNames = @_;
       my $row;
       my $column;
       my %hashMapeamentoArqNames;

      my $num = 0;
      print "- Mapeando arquivo 'discover.names' \n";
      foreach $row (0..@discoverNames-1){           
         foreach $column (0..@{$discoverNames[$row]}-1) {
            my $palavra = extrairNomes($discoverNames[$row][$column]);
            my %hashList = buscarSinonimos($palavra);   
            my $i += scalar keys %hashList;              
            $num = $num + 1;
            print "   $num - Termo: $palavra  - Quant. sinonimos: $i      ";
            usleep(100000);
            print ("\b" x (length("   $num - Termo: $palavra  - Quant. sinonimos: $i      ")));  
             
            if(length($palavra) > 0 and $i > 0 ){
               my $informacao = Informacao->new( string => $palavra, integer => $row);              
               $hashMapeamentoArqNames{$informacao->getTermo} = $informacao;              
            }            
       }                
   }
   
   print "\n"; 
   
   return %hashMapeamentoArqNames;
}

sub mapearArquivoData{
   $|=1;
   my @discoverNames = obterMatrizNames();
   my %parametroHashArqNames = identificarSinonimosDeSinonimos(@discoverNames);
   
   my @discoverData = @_;
   
   
   my $nomeDocumento;
   my $otherValue;
   my $newValue;
   my %newValue;
   my %hashOfHash; # Hash data contém Hash dos nomes correspondente a cada linha
   my $parametroHashArqNames;

   my $num = 0;
   print "- Mapeando objetos e adicionando ao hash, as informacoes do arquivo 'discover.data' \n";
   foreach my $row (0..@discoverData-1){    
        $nomeDocumento = $discoverData[$row][0];
        # print "$nomeDocumento \n";
         $num = $num + 1;
         print "    # Documento linha: $num      ";
         usleep(100000);
         print ("\b" x (length("    # Documento linha: $num      ")));       
         foreach my $value (sort values %parametroHashArqNames){  
         #Analisei que não havia necessidade de percorrer todas as colunas, verificando.
         #Posso acessar diretamente com a informação que já foi coletada no mapeamento do arquivo .names
         # que é a posição que ele esta no .data.       
             if(length($value->getIndexSinonimos) > 0){
                my $informacao = Informacao->new( string => $value->getTermo, integer => $value->getPosicao);
                $informacao->setValor(set => $discoverData[$row][$value->getPosicao]);
                $informacao->setNomeDocumento(set => $nomeDocumento);                
                $informacao->setIndexSinonimos(set => $value->getIndexSinonimos);
                $informacao->setPosicaoDocumento(set => $row);

                $hashOfHash{$nomeDocumento}{$value->getTermo}{$value->getPosicao}   =  $informacao;
             }
         }       

   }
   print "\n";

   return %hashOfHash;

}

sub alterarArquivoData{
   $|=1;
   my @discoverData =  @_;
   my $row;
   my $column;
   
   my %hashRef = mapearArquivoData(@discoverData);
   
   # # Lendo o arquivo discover.data
   # open(DISCOVERDATA, $DIRETORIO_DISCOVER.$DISCOVER_DATA) or die  "Couldn't open file "." ". $DISCOVER_DATA,", $!";		
   # print "- Lendo arquivo 'discover.data' \n";
   # while ( <DISCOVERDATA> ){
      # print ".";
      # usleep(100000);
     # chomp;
     # push @discoverData, [ split /,/ ];
   # }
   # print "\n";
   
   my @colunasSeremRemovidas;
   my $num = 0;
  
  print ">>>  Manipulando matriz do arquivo 'discover.data' \n";
  foreach my $docNome (sort keys  %hashRef) {#Nome do documento
      $num = $num + 1;
      print "     $num       ";
      usleep(100000);
      print ("\b" x (length("     $num       ")));
       foreach my $termo (sort keys %{ $hashRef{$docNome} }) {# Termo
          foreach my $posicao (sort keys %{ $hashRef{$docNome}{$termo} }) {# Posição
              my $posicaoTermoColuna = $hashRef{$docNome}{$termo}{$posicao}->getPosicao;
              my $string = $hashRef{$docNome}{$termo}{$posicao}->getIndexSinonimos;
              my $posicaoLinhaDocumento = $hashRef{$docNome}{$termo}{$posicao}->getPosicaoDocumento;
              my $valorTermo = $hashRef{$docNome}{$termo}{$posicao}->getValor;
              
              # print "Nome documento : " . $hashRef{$docNome}{$termo}{$posicao}->getNomeDocumento . "\n";
              # print "Termo  : " . $hashRef{$docNome}{$termo}{$posicao}->getTermo . "\n"; 
              # print "Posicao do termo : " . $posicaoTermoColuna . "\n";
              # print "Linha documento: ".$posicaoLinhaDocumento."\n";
              # print "Valor do termo no documento informado : " .$hashRef{$docNome}{$termo}{$posicao}->getValor . "\n";              
              # print "Index e nome sinonimos localizados: ".  $string ."\n\n\n";
              
              
               #### Rever melhoria
               if(length($string) > 0){                
                  my @array = split(";", $string);                
                  foreach (@array){ 
                     my $digito = extrairDigitoByColchetes($_);
                     push(@colunasSeremRemovidas, $digito);             
                     $discoverData[$posicaoLinhaDocumento][$posicaoTermoColuna] =  $discoverData[$posicaoLinhaDocumento][$posicaoTermoColuna] + $discoverData[$posicaoLinhaDocumento][$digito]  ;
                     $discoverData[$posicaoLinhaDocumento][$digito] = 0;
                  }
              }
           }    
       }
   }
   print "\n";
   
   my $num = 0;
    print ">>> Removendo colunas zeradas da matriz 'discover.data' \n";
   # Removendo colunas por linha;
   foreach $row (0..@discoverData-1){
       $num = $num + 1;
       print "     $num      ";
       usleep(100000);
       print ("\b" x (length("     $num      ")));
      foreach(@colunasSeremRemovidas){
         $discoverData[$row][$_] = "";
      }
   }
   print "\n";
   
   $num = 0;
   print " >>> Rescrevendo em novo arquivo, as linhas do arquivo 'discover.data' \n";
   # Rescrevendo o arquivo data
   open my $meuArquivo, ">", $MEU_DISCOVER_DATA or die "Can't create ".$MEU_DISCOVER_DATA."'\n";    
   foreach $row (0..@discoverData-1){    
      $num = $num + 1;
      print "    # Linha:    $num     ";
      usleep(100000);
      print ("\b" x (length("    # Linha:    $num     ")));
      my $linha = trim(join(',', @{$discoverData[$row]}));
      $linha =~ s/,,/,/g; 
      
      if($linha=~/(.*),$/){# Caso o último caractere seja uma vírgula, ele remove.
         chop($linha);
       }

      print  $meuArquivo "$linha\n"
   }
   close $meuArquivo;
   print "\n";
}


sub identificarSinonimosDeSinonimos{
       $|=1;
       my @discoverNames = @_;
       my $row;
       my $column;
       my $otherRow;
       my $otherColumn;
       my $palavraArquivo;
       my $encontrei = 0;
       my %novoHashMapeado = mapearArquivoNomes(@discoverNames);        
       my $novoHashMapeado;
       my $string;
       my $num = 0;
       
      print "- Buscando sinonimos de sinonimos e associando ao hash de 'mapeamento do arquivo names' \n";
      open my $meuArquivo, ">", $MEU_DISCOVER_NAMES or die "Can't create ".$MEU_DISCOVER_NAMES."'\n";    
       foreach $row (0..@discoverNames-1){                     
          foreach $column (0..@{$discoverNames[$row]}-1) {      
            my $palavra = extrairNomes($discoverNames[$row][$column]); 
            $num = $num + 1;
            print "   $num - $palavra                ";
            usleep(100000);
            print ("\b" x (length("   $num - $palavra                ")));                    
            my $key;           
            
            if(length($palavra) > 1){
               my $i = 0;              
               my %hashList = buscaRecursiva(buscarSinonimos($palavra));   
            
               #Listando sinônimos
               $i += scalar keys %hashList;
               print $meuArquivo "$palavra: ";
               if($i > 0 ){
                  foreach $key (sort keys %hashList){                                      
                     # Utilizando minha lista de sinônimos, verifico se ele esta no arquivo, caso esteja, eu removo a linha do mesmo no arquivo
                     # e marco a key que usei p/ busca no meuDiscover.names. Por exemplo [student] encontrei no arquivo. 
                      foreach $otherRow (0..@discoverNames-1){              
                        foreach $otherColumn (0..@{$discoverNames[$otherRow]}-1) {                          
                           $palavraArquivo = extrairNomes($discoverNames[$otherRow][$otherColumn]);                                                     
                           if(($key eq $palavraArquivo) and ($palavra ne $key)){
                              $encontrei = 1;
                               my $SEPARADORDADOS = "|";
                               my $CINICIO = "[";
                               my $CFIM = "]";
                               my $SEPARADORINFOR = ";";
                               # Formatando minha string que vai conter posição e termo (sinonimo):
                               # [3]|bookman;[4]|educatee; 
                               # O valor que vai ser de interesse, será o que esta entre colchetes.
                               $string = $string.$CINICIO.$otherRow.$CFIM.$SEPARADORDADOS.$key.$SEPARADORINFOR; 
                               $discoverNames[$otherRow][$otherColumn] = "";
                           }
                        }                                               
                     }
                    #Marco a palavra encontrada.
                    if($encontrei){                      
                        print $meuArquivo "[$key] | ";           
                     }else{
                         print $meuArquivo "$key | ";  
                     }
                     $encontrei = 0;                 
                  }                   
                   $novoHashMapeado{$palavra}->setIndexSinonimos(set => $string);
                   # Serve apenas para escrever no meuDiscover.names
                   if(length($string)){                   
                      my @array = split(";", $string);                
                      foreach (@array){ 
                        print $meuArquivo "\n          ~  $_      ";                     
                      }
                   }
                   #*************************************************
                   
                   $string = "";
               }else{
                  print $meuArquivo " (Não foram encontrados sinônimos.)";  
               }              
               print $meuArquivo "\n";  
             
             }
          }         
      } 
      print "\n";
      
   close $meuArquivo;     
   return %novoHashMapeado;             
}
my @discoverData = obterMatrizData();
alterarArquivoData(@discoverData);