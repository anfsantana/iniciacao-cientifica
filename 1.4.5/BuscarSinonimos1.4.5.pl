#!/usr/bin/perl
# Constantes
my($INDEX_NOUN, $DATA_NOUN, $DIRETORIO
   , $DISCOVER_DATA,$MEU_DISCOVER_DATA, $MEU_DISCOVER_NAMES
   , $DISCOVER_NAMES, $DIRETORIO_DISCOVER, $LOG
   , $MINIMOSINONIMOS, $ZERO);
   
$INDEX_NOUN = "index.noun";
$DATA_NOUN = "data.noun";
#$DIRETORIO = "D:/Projetos/WordNet/WordNet/dict/";
$DIRETORIO = "C:/WordNet/dict/";
$DISCOVER_DATA = "discover.data";
$MEU_DISCOVER_DATA = "meuDiscover.data";
$MEU_DISCOVER_NAMES = "meuDiscover.names";
$DISCOVER_NAMES = "discover.names";
$DIRETORIO_DISCOVER = "C:/WordNet/";
$LOG = "Log/logProcessamento.log";
# perl trim function - remove leading and trailing whitespace
use strict;
#use warnings;
use Informacao;
use Time::HiRes qw(usleep);     
$ZERO = 0.00;

# Remover espaços antes e depois de uma string
sub trim($)
{
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

sub extrairPalavras($){
   my($linha, $nome);
   $linha  = shift;   
   ($nome) = $linha =~ /(([a-z]){1}\S.*\b\s(@))/ ;
   ($linha) = $nome =~ /(([a-z]){1}\S.*.([a-z]){1}\b)/; 
                      
    return $linha;                   
}

sub extrairNomes{
   my($new,  $palavra);
   $new = $_[0];
   ($palavra) = $new =~ /^(\"[a-zA-z]+\")/;
   ($new) = $palavra =~ /([a-zA-z]+)/;
   
   return ($new);
   
}

sub extrairDigitoByColchetes{
   my($new, $digito);
   $new = $_[0];
   ($digito) = $new =~ /(\b\d*[\d])/;
   
   
   return ($digito);
   
}

sub obterMatrizNames(){
      $|= 1;
      my(@discoverNames, $num, $log, $start_run, $end_run, $run_time);
      $num = 0;
      open $log, ">>", $LOG or die "Can't create ".$LOG."'\n";   
      open(DISCOVERNAMES, $DIRETORIO_DISCOVER.$DISCOVER_NAMES) or die  "Couldn't open file "." ".$DISCOVER_NAMES,", $!";		
      print "- Lendo arquivo 'discover.names' \n";
      print $log " [".localtime."]- Lendo arquivo 'discover.names' \n";
      $start_run = time();
      while ( <DISCOVERNAMES> ){         
         chomp;
         push @discoverNames, [ split /,/ ];
         $num = $num + 1;         
         print "  -> $num  - ".extrairNomes($_)."                  ";
         usleep(100000);
         print ("\b" x (length("                                                                                  ")));  
         print ("\b" x (length("  -> $num  - ".extrairNomes($_)."                  ")));
      }
      close(DISCOVERNAMES);
      $end_run = time();
      $run_time = $end_run - $start_run;
      print $log " [".localtime."] - Quantidade lida:  $num   ";   
      print "\n    -> Tempo de execucao: $run_time segundo(s) ";   
      print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";    
      print "\n\n";
      close $log;
      $MINIMOSINONIMOS = 10; # Ideia: Colocar um calculo para escolhe a quantidade adequada mínima para a lista de sinônimos
   return @discoverNames;
   
}

sub obterMatrizData(){
   my(@discoverData, $num, $log, $start_run, $end_run, $run_time);
   $|=1;
   $num = 0;
   open $log, ">>", $LOG or die "Can't create ".$LOG."'\n";    
   open(DISCOVERDATA, $DIRETORIO_DISCOVER.$DISCOVER_DATA) or die  "Couldn't open file "." ". $DISCOVER_DATA,", $!";		
   print "- Lendo arquivo 'discover.data' \n";
   print $log " [".localtime."] - Lendo arquivo 'discover.data' \n";
   $start_run = time();
   while ( <DISCOVERDATA> ){
       $num = $num + 1;
       print "  -> $num                                                                   ";
       usleep(100000);
       print ("\b" x (length("                                                                             ")));  
       print ("\b" x (length("  -> $num                                                                  ")));
       chomp;
       push @discoverData, [ split /,/ ];
   }   
   close(DISCOVERDATA);
   $end_run = time();
   $run_time = $end_run - $start_run;
   print $log " [".localtime."] - Quantidade lida:  $num   ";
   print "\n    -> Tempo de execucao: $run_time segundo(s) ";
   print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";
   close $log;
   print "\n\n";
   return @discoverData;
   
}

# Função para obter um hash de sinônimos.
# - parâmetro: palavra para busca.
sub buscarSinonimos($){
        my($word, $number, $linha, $nome, $id, $linha2,
            $w, $onlyWord, %data, @palavras, @ids, @sorted_ids);
           
	$word = trim($_[0]);
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
	
	@ids = split(" ",trim($number)); #Pega os ids na linha do arquivo.	
        @sorted_ids = sort { $a <=> $b } @ids; #Ordena os ids.
	foreach (@sorted_ids){ 
                 $id = $_;
                 open(DATA, $DIRETORIO.$DATA_NOUN) or die  "Couldn't open file "." ". $DATA_NOUN,", $!"; #Ler o arquivo data.noun		
                 while(<DATA>){		  
                     if(/^$id /){#Pega o ID da lista ordenada e pesquisa as palavras que são relacionadas ao mesmo.
                       $linha2 = trim($_);                                            
                       @palavras = split(/[0-9]/, extrairPalavras($linha2)); # Obtém as palavras da linha do arquivo
                       foreach(@palavras){ # Adiciona as palavras encontradas ao hash $data
                          $w = trim($_);                           
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


sub buscaRecursiva{
  my($k, $i, $key, %newHash, %retorno, %data);
  $k = 0;
  $i = 0;
  %data = @_;
  $k += scalar keys %data;
  if($k == 0 or $k >= $MINIMOSINONIMOS){
      return %data;
   }
   foreach $key (sort keys %data){
        if(length(trim($key)) > 2){
	  %retorno =  buscarSinonimos($key);
          @data{keys %retorno} = values %retorno;
      }
   }          
   $i += scalar keys %data; 
   if($i == $k or $i == 0 ){      
      return %data;
   }  
   return buscaRecursiva(%data); 
   
}

sub mapearArquivoNomes{
       $|=1;
       my(@discoverNames, %hashMapeamentoArqNames, %hashList, 
          $row, $column, $num, $log, $end_run, $run_time,
          $start_run, $palavra, $i, $informacao);
          
       @discoverNames = @_;       
       $column = 0;       
       $num = 0;
       open $log, ">>", $LOG or die "Can't create ".$LOG."'\n";   
       print "- Mapeando arquivo 'discover.names' \n";
       print $log " [".localtime."] - Mapeando arquivo 'discover.names' \n";
       $start_run = time();       
       foreach $row (0..@discoverNames-1){  
			$i = 0;	   
            $palavra = extrairNomes($discoverNames[$row][$column]);
            %hashList = buscarSinonimos($palavra);   
            $i += scalar keys %hashList;              
            $num = $num + 1;
            print "  ->  $num - Termo: $palavra  - Quant. sinonimos: $i      ";           
            usleep(100000);
            print ("\b" x (length("                                                                           ")));  
            print ("\b" x (length(" ->  $num - Termo: $palavra  - Quant. sinonimos: $i      ")));  
             
            if(length($palavra) > 0 and $i > 0 ){
               $informacao = Informacao->new( string => $palavra, integer => $row);              
               $hashMapeamentoArqNames{$informacao->getTermo} = $informacao;              
            }                            
   }
   $end_run = time();
   $run_time = $end_run - $start_run;
   print $log " [".localtime."] - Quantidade lida:  $num   ";
   print "\n    -> Tempo de execucao: $run_time segundo(s) ";
   print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";
   close $log;
   print "\n\n"; 
   
   return %hashMapeamentoArqNames;
}

sub mapearArquivoData{
   $|=1;
   my(@discoverNames, %parametroHashArqNames
     , @discoverData, $nomeDocumento
     , $otherValue , %newValue
     , %hashOfHash # Hash data contém Hash dos nomes correspondente a cada linha
     , $parametroHashArqNames, $num, $start_run
     , $informacao, $end_run, $run_time, $log);
   
   @discoverNames = obterMatrizNames();
   %parametroHashArqNames = identificarSinonimosDeSinonimos(@discoverNames);   
   @discoverData = @_;
   
   $num = 0;
   open $log, ">>", $LOG or die "Can't create ".$LOG."'\n";   
   print "- Mapeando objetos e adicionando ao hash, as infor. do arquivo 'discover.data' \n";
   print $log " [".localtime."] - Mapeando objetos e adicionando ao hash, as informacoes do arquivo 'discover.data' \n";
   $start_run = time();
   foreach my $row (0..@discoverData-1){    
        $nomeDocumento = $discoverData[$row][0];
         $num = $num + 1;        
         foreach my $value (sort values %parametroHashArqNames){             
             #Analisei que não havia necessidade de percorrer todas as colunas, verificando.
             #Posso acessar diretamente com a informação que já foi coletada no mapeamento do arquivo .names
             # que é a posição que ele esta no .data.       
             if(length($value->getIndexSinonimos) > 0){
                print "    # Documento linha: $num  P.S.S.  = ".$value->getTermo."       ";
                usleep(100000);
                print ("\b" x (length("                                                                             ")));  
                print ("\b" x (length("    # Documento linha: $num  P.S.S.  = ".$value->getTermo."       ")));       
                $informacao = Informacao->new( string => $value->getTermo, integer => $value->getPosicao);
                $informacao->setValor(set => $discoverData[$row][$value->getPosicao]);
                $informacao->setNomeDocumento(set => $nomeDocumento);                
                $informacao->setIndexSinonimos(set => $value->getIndexSinonimos);
                $informacao->setPosicaoDocumento(set => $row);

                $hashOfHash{$nomeDocumento}{$value->getTermo}{$value->getPosicao}   =  $informacao;
             }
         }       

   }
   $end_run = time();
   $run_time = $end_run - $start_run;
   print $log " [".localtime."] - Quantidade lida:  $num   ";   
   print "\n    -> Tempo de execucao: $run_time segundo(s) ";   
   print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";
   print "\n\n";
   close $log;
   return %hashOfHash;

}

sub alterarArquivoData{
   $|=1;
   
      , $log, $start_run, $num, $digito, $end_run, $run_time, $linha); 
   @discoverData =  @_;
   %hashRef = mapearArquivoData(@discoverData);   
   $num = 0;
   
   open  $log, ">>", $LOG or die "Can't create ".$LOG."'\n";   
   print ">>>  Manipulando matriz do arquivo 'discover.data' \n";
   print $log " [".localtime."] >>>  Manipulando matriz do arquivo 'discover.data' \n";
   $start_run = time();   
   foreach my $docNome (sort keys  %hashRef) {#Nome do documento
       $num = $num + 1;     
       foreach my $termo (sort keys %{ $hashRef{$docNome} }) {# Termo
          print "  ->    $num - $termo       ";
          usleep(100000);
          print ("\b" x (length("                                                                             ")));  
          print ("\b" x (length("  ->    $num - $termo       ")));
          foreach my $posicao (sort keys %{ $hashRef{$docNome}{$termo} }) {# Posição
              my $posicaoTermoColuna = $hashRef{$docNome}{$termo}{$posicao}->getPosicao;
              my $string = $hashRef{$docNome}{$termo}{$posicao}->getIndexSinonimos;
              my $posicaoLinhaDocumento = $hashRef{$docNome}{$termo}{$posicao}->getPosicaoDocumento;
              my $valorTermo = $hashRef{$docNome}{$termo}{$posicao}->getValor;
              if(length($string) > 0){                
                  my @array = split(";", $string);                
                  foreach (@array){ 
                     $digito = extrairDigitoByColchetes($_);
                     push(@colunasSeremRemovidas, $digito);             
                     $discoverData[$posicaoLinhaDocumento][$posicaoTermoColuna] = sprintf("%.2f", $discoverData[$posicaoLinhaDocumento][$posicaoTermoColuna] + $discoverData[$posicaoLinhaDocumento][$digito]);
                     $discoverData[$posicaoLinhaDocumento][$digito] = sprintf("%.2f", $ZERO);
                  }
              }
           }    
       }
   }
   $end_run = time();
   $run_time = $end_run - $start_run;
   print $log " [".localtime."] - Quantidade lida:  $num   ";   
   print "\n    -> Tempo de execucao: $run_time segundo(s) ";   
   print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";   
   print "\n\n";
   
   $num = 0;   
   print ">>> Removendo colunas zeradas da matriz 'discover.data' \n";
   print $log " [".localtime."] >>> Removendo colunas zeradas da matriz 'discover.data' \n";
   # Removendo colunas por linha;
   $start_run = time();
   foreach $row (0..@discoverData-1){
       $num = $num + 1;
       print "   -> Contador:  $num      ";
       usleep(100000);
       print ("\b" x (length("                                                                             ")));  
       print ("\b" x (length("   -> Contador:  $num      ")));
      foreach(@colunasSeremRemovidas){
         $discoverData[$row][$_] = "[REMOVER]";
      }
   }
   $end_run = time();
   $run_time = $end_run - $start_run;
   print $log " [".localtime."] - Quantidade lida:  $num   ";   
   print "\n      -> Tempo de execucao: $run_time segundo(s) ";   
   print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";     
   print "\n\n";
   
   $num = 0;
   print " >>> Rescrevendo em novo arquivo, as linhas do arquivo 'discover.data' \n";
   print $log " [".localtime."] >>> Rescrevendo em novo arquivo, as linhas do arquivo 'discover.data' \n";
   # Rescrevendo o arquivo data   
   open my $meuArquivo, ">", $MEU_DISCOVER_DATA or die "Can't create ".$MEU_DISCOVER_DATA."'\n";    
   $start_run = time();
   foreach $row (0..@discoverData-1){    
      $num = $num + 1;
      print "    -> Linha:    $num     ";
      usleep(100000);
      print ("\b" x (length("                                                                             ")));  
      print ("\b" x (length("    -> Linha:    $num           ")));
      $linha = trim(join(',', @{$discoverData[$row]}));          
      if($linha=~/(.*),$/){# Caso o último caractere seja uma vírgula, ele remove.
         chop($linha);
       }
      $linha =~  s/,[REMOVER],/,/igmx; 
      print  $meuArquivo $linha."\n"
   }
   $end_run = time();
   $run_time = $end_run - $start_run;
   print $log " [".localtime."] - Quantidade lida:  $num   ";   
   print "\n    -> Tempo de execucao: $run_time segundo(s) ";   
   print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n";        
   close $meuArquivo;
   close $log;
   print "\n\n";
}


sub identificarSinonimosDeSinonimos{
       $|=1;
       my(@discoverNames, $row, $column, $otherRow
         , $otherColumn, $palavraArquivo
         , $encontrei, %novoHashMapeado, $string, $num
         , $palavra, $start_run, $end_run
         , $run_time, $key, $i, %hashList, $SEPARADORDADOS
         , $CINICIO, $CFIM, $SEPARADORINFOR);
         
       @discoverNames = @_;
       $column = 0;
       $encontrei = 0;
       %novoHashMapeado = mapearArquivoNomes(@discoverNames);        
       $num = 0;
       $SEPARADORDADOS = "|";
       $CINICIO = "[";
       $CFIM = "]";
       $SEPARADORINFOR = ";";
       
       open my $log, ">>", $LOG or die "Can't create ".$LOG."'\n";    
       print "- Buscando sinonimos de sinonimos e associando ao hash de 'mapeamento do arquivo names' \n";
       print $log " [".localtime."] - Buscando sinonimos de sinonimos e associando ao hash de 'mapeamento do arquivo names' \n";
       open my $meuArquivo, ">", $MEU_DISCOVER_NAMES or die "Can't create ".$MEU_DISCOVER_NAMES."'\n"; 
       $start_run = time();   
       # foreach $row (0..@discoverNames-1){   
       foreach my $chave (sort keys %novoHashMapeado){                                      
            #$palavra = extrairNomes($discoverNames[$row][$column]); 
            $palavra = $novoHashMapeado{$chave}->getTermo;
            $num = $num + 1;
            print "  ->  $num - $palavra                ";
            usleep(100000);
            print ("\b" x (length("                                                                             ")));  
            print ("\b" x (length(" ->  $num - $palavra                ")));                            
            
            if(length($palavra) > 1){
               $i = 0;              
               %hashList = buscaRecursiva(buscarSinonimos($palavra));               
               #Listando sinônimos
               $i += scalar keys %hashList;
               print $meuArquivo "$palavra: ";
               $otherColumn = 0;
               if($i > 0 ){
                  foreach $key (sort keys %hashList){                                      
                     # Utilizando minha lista de sinônimos, verifico se ele esta no arquivo, caso esteja, eu removo a linha do mesmo no arquivo
                     # e marco a key que usei p/ busca no meuDiscover.names. Por exemplo [student] encontrei no arquivo. 
                      foreach $otherRow (0..@discoverNames-1){                                                              
                           $palavraArquivo = extrairNomes($discoverNames[$otherRow][$otherColumn]);                                                     
                           if(($key eq $palavraArquivo) and ($palavra ne $key)){
                               $encontrei = 1;                              
                               # Formatando minha string que vai conter posição e termo (sinonimo):
                               # [3]|bookman;[4]|educatee; 
                               # O valor que vai ser de interesse, será o que esta entre colchetes.
                               $string = $string.$CINICIO.$otherRow.$CFIM.$SEPARADORDADOS.$key.$SEPARADORINFOR; 
                               $discoverNames[$otherRow][$otherColumn] = "";
                               last;
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
     $end_run = time();
     $run_time = $end_run - $start_run;
     print $log " [".localtime."] - Quantidade lida:  $num   ";   
     print "\n    -> Tempo de execucao: $run_time segundo(s) ";
     print $log "\n  [".localtime."]  -> Tempo de execucao: $run_time segundo(s) \n\n ";
     print "\n\n";
     close $log;
     close $meuArquivo;     
     return %novoHashMapeado;             
}

my($log, @discoverData);

open $log, ">>", $LOG or die "Can't create ".$LOG."'\n";    
print $log "\n ========= Inicio processamento: ".localtime."  ========================================================== \n\n";
print      " \n ============= Inicio processamento: ".localtime."  ============= \n\n ";
close $log;
@discoverData = obterMatrizData();
alterarArquivoData(@discoverData);

print      " \n ============= Fim processamento: ".localtime."  ============= \n\n ";
print $log " \n ============= Fim processamento: ".localtime." ========================================================== \n\n";
close $log;

