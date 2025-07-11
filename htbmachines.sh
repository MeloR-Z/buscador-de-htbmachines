#!/bin/bash


green="\e[0;32m\033[1m"
endC="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

function ctrl_c(){
echo -e "${red}\n [!] Saliendo${endC}"
exit 1 
}

trap ctrl_c INT


uri_global=https://htbmachines.github.io/bundle.js




helpanel(){
	

	echo -e "\n${blue}[+]${endC} ${yellow}Uso:${endC}"
	echo -e "\n${green}[+]${endC} ${purple}-u${endC} ${gray}Descargar/actualizar recursos${endC}"
	echo -e "\n${green}[+]${endC} ${purple}-m${endC} ${gray}Buscar máquina por su nombre${endC}"
	echo -e "\n${green}[+]${endC} ${purple} -lm ${endC} ${gray}Mostrar solo el link al writeup de la máquina${endC}"
	echo -e "\n${green}[+]${endC} ${purple}-h${endC} ${gray}Mostrar el panel de ayuda${endC}"
	echo -e "\n${green}[+]${endC} ${purple}-d${endC} ${gray}Buscar máquinas por dificultad${endC}"
	echo -e "\n${green}[+]${endC} ${purple}-o${endC} ${gray}Buscar máquina por sistema operativo${endC}"
	echo -e "\n${green}[+]${endC} ${purple}-i${endC} ${gray}Buscar el nombre de la máquina por su IP${endC}"



	

}




update_bundle(){

if [ ! -f bundle.js ]; then 
	echo '[+] Obteniendo recursos necesarios' 
	curl -s $uri_global > bundle.js
	cat bundle.js | js-beautify | sponge bundle.js

else 

echo  -e "\n      [+] -- Archivo ya descargado "
echo -e '\n [+] -- Buscando actualizaciones....  '
curl -s $uri_global > temp_bundle.js 
cat temp_bundle.js | js-beautify | sponge temp_bundle.js
archivo_en_sistema=$(cat bundle.js | md5sum | cut -d' ' -f 1)
archivo_para_comparar=$(cat temp_bundle.js | md5sum | cut -d' ' -f 1)

	if [ "$archivo_en_sistema" != "$archivo_para_comparar" ]; then

		echo '[+]-- Update encontrada...' 
		echo '[+]-- Actualizando el paquete bundle....'
		rm -f bundle.js
		mv temp_bundle.js bundle.js
		cat bundle.js | js-beautify | sponge bundle.js
		

	else 
		echo "[+] -- No hay updates"
		rm -f temp_bundle.js

	fi


fi


}


#elegi m ?
declare -i m_countet=0



#buscar maquina por IP

searchIP(){

	maquina_porIP=$(cat bundle.js | grep -B 3 $1  | grep name | awk '{print $2}' | tr '"' ' ' | tr ',' ' ')
	
	if [ -n "$maquina_porIP" ]; then
		echo -e "\n ${gray}[+] -- La maquina con la ip ${endC} ${purple}$1 ${endC} ${gray}es${endC} ${purple}$maquina_porIP${endC}"
	else 
		echo -e "\n ${red} [+] -- No existe una maquina con la ip${endC} ${purple}$1${endC}"
	fi
}


# Buscar por skills 




searchBySkills(){

maquinas_por_skills=$(cat bundle.js | grep -B 6  "skills:" | grep "$1" -B 7 | grep "name:" | awk '{print $2}' | tr -d '"' | tr -d ",")
maquinas_por_skills_num=$(cat bundle.js | grep -B 6  "skills:" | grep "$1" -B 7 | grep "name:" | awk '{print $2}' | tr -d '"' | tr -d "," | wc -l)

if [ "$maquinas_por_skills" ]; then 
	echo -e ${gray}"Hay un total de:${endC} ${purple}$maquinas_por_skills_num${endC} ${gray}donde se usa la skill: ${endC}${purple}$1${endC}\n "
	echo $maquinas_por_skills | tr " " "\n"

else 
	echo -e " ${red}[+] No hay maquinas con esas skills${endC} "

fi
}

#Buscar por sistema operativo

search_byOS(){



maquina_por_os=$(grep -P  -B 5 '(?=.*so)(?=.*'$1')' bundle.js | grep name | awk '{print $2}' | tr '"' ' ' | tr ","  " ")
numero_de_maquinas_por_os=$(grep -P  -B 5 '(?=.*so)(?=.*Windows)' bundle.js | grep name | awk '{print $2}' | tr '"' ' ' | tr ","  " " | wc -l)

echo "[+] --- Hay un total de "$numero_de_maquinas_por_os" maquinas "$1"  "
echo '\n' 
echo $maquina_por_os | tr " "  "\n " | column

}






#buscar maquina por dificulta


search_byDificultad(){

maquina_por_dicultad=$(grep -P -B 5 '(?=.*dificultad)(?=.*'$1')' bundle.js | grep name | awk '{print $2}' | tr -d '"' | tr -d ',')
numero_de_maquinas=$(grep -P -B 5 '(?=.*dificultad)(?=.*'$1')' bundle.js | grep name | awk '{print $2}' | tr '"' ' ' | tr ',' ' '| wc -l)

case $1 in

	Dificil|dificil|Difícil|Insane|insane)
		echo -e "[+] ${gray} Total de maquinas en dificulta${endC} ${red}$1${endC} ${gray}son:${endC} ${red}$numero_de_maquinas${endC}\n" ;;
	Facil|facil|Fácil)
		echo -e "[+] ${gray} Total de maquinas en dificulta${endC} ${green}$1${endC} ${gray}son:${endC} ${green}$numero_de_maquinas${endC}\n" ;;

	Media|media)
		echo -e "[+] ${gray} Total de maquinas en dificulta${endC} ${yellow}$1${endC} ${gray}son:${endC} ${yellow}$numero_de_maquinas${endC}\n" ;;


esac

echo "$maquina_por_dicultad" | tr " " "\n" | column




}

#buscar maquinas
search_machine(){
 busqueda_maquina=$(cat bundle.js | grep -P -A 10 '(?=.*name)(?=.*'$machine')' | grep -vE "id|resuelta|sku|}" | awk '{print  $1 $2}' )
 if [ -n "$busqueda_maquina" ]; then 
	echo -e "${purple}Maquina${endC} ${red}$machine${enC} ${purple}en busqueda......${endC}\n" ${gray}
 	echo 	$busqueda_maquina | tr ' ' '\n'
 else
	echo -e "${red} [+] No exite una maquina con el nombre ${endC} ${purple}$machine${endC}"
 fi



}

# buscar por dificultad y por sistema

searchBy_os_dificultad(){



maquinas_por_dificultad_y_os=$(cat bundle.js | grep -B 5 -P  '(?=.*dificultad)(?=.*'$dificultad')' | grep -B 5 "$os" | grep "name:")
numero_de_maquinas_por_osydificultad=$(echo $maquinas_por_dificultad_y_os | tr -d '"' | tr -d ',' | tr ' ' '\n' | grep -v "name" | wc -l)
echo -e " ${yellow}[+] Hay un total de${endC} ${purple}$numero_de_maquinas_por_osydificultad${endC} ${yellow}maquinas en dificultad${endC} ${purple}$dificultad${endC} ${yellow}y sistema operativo${endC} ${purple}$os${endC}\n"
echo $maquinas_por_dificultad_y_os | tr -d '"' | tr -d ',' | tr ' ' '\n' | grep -v "name"


}




while getopts m:hi:d:us:o: argumentos; do 

	case $argumentos in

		m) let m_countet+=1; machine=$OPTARG;;
		h) ;;
		i) let m_countet+=3; ip=$OPTARG;;
		d) let m_countet+=4; dificultad=$OPTARG
			case $dificultad in


				Dificil|dificil) dificultad=Difícil;;
				Facil|facil)   dificultad=Fácil;;
				Media|media)   dificultad=Media;;
				Insane|insane) dificultad=Insane;;
				*) echo "Dificultad no existe"

			esac 



			



		;;
		u) let m_countet+=2;; 

		o) let m_countet+=5; os=$OPTARG
			case $os in  
			
				w|W) os=Windows;;
				l|L) os=Linux;;
				*) echo "Sistema operativo no exite";;

			esac 

			;;

		s)skills=$OPTARG; let m_countet+=6;;
		l) let m_countet+=10;;




		
		

	esac


done 


if [ $m_countet -eq 1 ]; then

	search_machine $machine 

elif [ $m_countet -eq 2 ]; then 

	update_bundle

elif [ $m_countet -eq 3 ]; then 

	searchIP $ip

elif [ $m_countet -eq 4 ]; then 

	search_byDificultad $dificultad


elif  [ $m_countet -eq 5 ]; then 

	search_byOS $os 



elif [ $m_countet -eq 11 ]; then 

		link=$(search_machine | grep youtube | cut -d'"' -f 2)

		if [ $link ]; then 
			echo -e "\n ${yellow}[+] Link de youtube:${endC} ${red}$link${endC}"
		else
			echo -e "${red} [+] No exite una maquina con el nombre ${endC} ${purple}$machine${endC}"
		fi 



elif [ "$dificultad" ] && [ "$os" ]; then 

searchBy_os_dificultad 



elif [ $m_countet -eq 6 ]; then 


searchBySkills "$skills"

else
 
	helpanel

fi
