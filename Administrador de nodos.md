Administrador de versiones de nodo Estado de la construcción versión nvm Mejores prácticas de CII
Tabla de contenido
Acerca de
Instalación y actualización
Instalar y actualizar el script
Notas adicionales
Solución de problemas en Linux
Solución de problemas en macOS
Ansible
Verificar instalación
Notas importantes
Instalación de Git
Manual de instalación
Actualización manual
Uso
Soporte a largo plazo
Migración de paquetes globales durante la instalación
Paquetes globales predeterminados desde archivo durante la instalación
io.js
Versión del sistema del nodo
Listado de versiones
Configuración de colores personalizados
Colores personalizados persistentes
Suprimir la salida coloreada
Restaurando PATH
Establecer la versión de nodo predeterminada
Usa un espejo de binarios de nodos
.nvmrc
Integración más profunda de Shell
intento
Llamar automáticamente nvm use
zsh
Llamar nvm useautomáticamente en un directorio con un .nvmrcarchivo
pescado
Llamar nvm useautomáticamente en un directorio con un .nvmrcarchivo
Licencia
Ejecución de pruebas
Variables de entorno
Finalización de Bash
Uso
Problemas de compatibilidad
Instalación de nvm en Alpine Linux
Desinstalación / Eliminación
Desinstalación manual
Docker para el entorno de desarrollo
Problemas
Solución de problemas de macOS
Acerca de
nvm es un administrador de versiones para node.js , diseñado para ser instalado por usuario e invocado por shell. nvmfunciona en cualquier shell compatible con POSIX (sh, dash, ksh, zsh, bash), en particular en estas plataformas: unix, macOS y windows WSL.


Instalación y actualización
Instalar y actualizar el script
Para instalar o actualizar nvm, debe ejecutar el script de instalación . Para hacer eso, puede descargar y ejecutar el script manualmente, o usar el siguiente comando cURL o Wget:

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | intento
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | intento
Al ejecutar cualquiera de los comandos anteriores, se descarga un script y se ejecuta. El guión clona el repositorio NVM a ~/.nvm, y los intentos de añadir las líneas de código del siguiente fragmento de código en el archivo de perfil correcto ( ~/.bash_profile, ~/.zshrc, ~/.profile, o ~/.bashrc).


export NVM_DIR = " $ ( [ -z  " $ {XDG_CONFIG_HOME-} " ] &&  printf % s " $ {HOME} /.nvm "  ||  printf % s " $ {XDG_CONFIG_HOME} / nvm " ) " 
[ -s  " $ NVM_DIR /nvm.sh " ] &&  \.  " $ NVM_DIR /nvm.sh "  # Esto carga nvm
Notas adicionales
Si la variable de entorno $XDG_CONFIG_HOMEestá presente, colocará los nvmarchivos allí.

Puede agregar --no-useal final del script anterior (... nvm.sh --no-use) para posponer el uso nvmhasta que uselo haga manualmente .

Puede personalizar la fuente, directorio, el perfil y la versión de instalar mediante el uso NVM_SOURCE, NVM_DIR, PROFILE, y NODE_VERSIONvariables. Por ejemplo: curl ... | NVM_DIR="path/to/nvm". Asegúrese de que NVM_DIRno contenga una barra inclinada al final.

El instalador puede usar git, curlo wgetdescargar nvm, lo que esté disponible.

Solución de problemas en Linux
En Linux, después de ejecutar el script de instalación, si recibe nvm: command not foundo no ve comentarios de su terminal después de escribir command -v nvm, simplemente cierre su terminal actual, abra un nuevo terminal e intente verificar nuevamente. Alternativamente, puede ejecutar ejecutar los siguientes comandos para los diferentes shells en la línea de comandos:

bash: source ~/.bashrc

zsh: source ~/.zshrc

ksh: . ~/.profile

These should pick up the nvm command.

Troubleshooting on macOS
Since OS X 10.9, /usr/bin/git has been preset by Xcode command line tools, which means we can't properly detect if Git is installed or not. You need to manually install the Xcode command line tools before running the install script, otherwise, it'll fail. (see #1782)

If you get nvm: command not found after running the install script, one of the following might be the reason:

Since macOS 10.15, the default shell is zsh and nvm will look for .zshrc to update, none is installed by default. Create one with touch ~/.zshrc and run the install script again.

Si usa bash, el shell predeterminado anterior, es posible que su sistema no tenga un .bash_profilearchivo donde se configura el comando. Cree uno con touch ~/.bash_profiley vuelva a ejecutar el script de instalación. Luego, corre source ~/.bash_profilepara tomar el nvmcomando.

Lo ha utilizado anteriormente bash, pero lo ha zshinstalado. Es necesario añadir manualmente estas líneas a ~/.zshrcy correr . ~/.zshrc.

Es posible que deba reiniciar su instancia de terminal o ejecutar . ~/.nvm/nvm.sh. Reiniciar su terminal / abrir una nueva pestaña / ventana, o ejecutar el comando de origen cargará el comando y la nueva configuración.

Si lo anterior no ayudó, es posible que deba reiniciar su instancia de terminal. Intente abrir una nueva pestaña / ventana en su terminal y vuelva a intentarlo.

Si lo anterior no soluciona el problema, puede intentar lo siguiente:

Si usa bash, es posible que su .bash_profile(o ~/.profile) no obtenga sus ~/.bashrcarchivos correctamente. Puede solucionar este problema agregando source ~/<your_profile_file>o siguiendo el siguiente paso a continuación.

Trate de añadir el fragmento de la sección de la instalación , que se encuentra en el directorio correcto y cargas NVM NVM, a su perfil habitual ( ~/.bash_profile, ~/.zshrc, ~/.profile, o ~/.bashrc).

Para obtener más información sobre este problema y posibles soluciones, consulte aquí.

Ansible
Puedes usar una tarea:

- nombre : shell nvm
   : >     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | intento

  argumentos :
     crea : " {{ansible_env.HOME}} /. nvm / nvm.sh "
Verificar instalación
Para verificar que nvm se ha instalado, haga lo siguiente:

comando -v nvm
que debería aparecer nvmsi la instalación se realizó correctamente. Tenga en cuenta que which nvmno funcionará, ya que nvmes una función de shell de origen, no un binario ejecutable.

Notas importantes
Si está ejecutando un sistema sin binarios preempaquetados disponibles, lo que significa que va a instalar nodejs o io.js desde su código fuente, debe asegurarse de que su sistema tenga un compilador C ++. Para OS X, Xcode funcionará, para GNU / Linux basado en Debian / Ubuntu, los paquetes build-essentialy libssl-devfuncionan.

Nota: nvm también es compatible con Windows en algunos casos. Debería funcionar a través de WSL (Subsistema de Windows para Linux) según la versión de WSL. También debería funcionar con GitBash (MSYS) o Cygwin . De lo contrario, para Windows, existen algunas alternativas, que no son compatibles ni desarrolladas por nosotros:

nvm-windows
nodista
nvs
Nota: nvm no es compatible con Fish (ver # 303 ). Existen alternativas, que no son apoyadas ni desarrolladas por nosotros:

bass te permite usar utilidades escritas para Bash en concha de pescado
fast-nvm-fish solo funciona con números de versión (no alias) pero no ralentiza significativamente el inicio de su shell
complemento plugin-nvm para Oh My Fish , que hace que nvm y sus terminaciones estén disponibles en concha de pescado
fnm - pescador administrador de versiones basado en para peces
fish-nvm : envuelve nvm para peces, retrasa la obtención de nvm hasta que se utiliza realmente.
Nota: Todavía tenemos algunos problemas con FreeBSD, porque no existe un binario preconstruido oficial para FreeBSD, y la compilación desde la fuente puede necesitar parches ; ver el ticket de emisión:

[# 900] [Error] Nodejs en FreeBSD puede necesitar un parche
nodejs / node # 3716
Nota: En OS X, si no tiene Xcode instalado y no desea descargar el archivo de ~ 4.3GB, puede instalar el Command Line Tools. Puede consultar esta publicación de blog sobre cómo hacerlo:

Cómo instalar herramientas de línea de comandos en OS X Mavericks y Yosemite (sin Xcode)
Nota: En OS X, si tiene / tuvo un nodo de "sistema" instalado y desea instalar módulos globalmente, tenga en cuenta que:

Cuando lo use nvm, no necesita sudoinstalar globalmente un módulo con npm -g, así que en lugar de hacerlo sudo npm install -g grunt, hágalo en su lugarnpm install -g grunt
Si tiene un ~/.npmrcarchivo, asegúrese de que no contenga ninguna prefixconfiguración (que no sea compatible con nvm)
Puede (¿pero no debería?) Mantener la instalación del nodo del "sistema" anterior, pero nvmsolo estará disponible para su cuenta de usuario (la que se utilizó para instalar nvm). Esto podría causar discrepancias en la versión, ya que otros usuarios usarán /usr/local/lib/node_modules/*VS su cuenta de usuario usando~/.nvm/versions/node/vX.X.X/lib/node_modules/*
La instalación de Homebrew no es compatible. Si tiene problemas con Homebrew-installed nvm, por favor brew uninstall, instálelo siguiendo las instrucciones a continuación, antes de presentar un problema.

Nota: Si está utilizando zsh, puede instalarlo fácilmente nvmcomo un complemento zsh. Instalar zsh-nvmy ejecutar nvm upgradepara actualizar.

Nota: Las versiones de Git anteriores a la v1.7 pueden enfrentar un problema de clonación de la nvmfuente de GitHub a través del protocolo https, y también hay un comportamiento diferente de git antes de la v1.6, y git anterior a la v1.17.10 no puede clonar etiquetas, por lo que el mínimo requerido La versión de git es v1.7.10. Si está interesado en el problema que mencionamos aquí, consulte el artículo sobre errores de clonación HTTPS de GitHub .

Instalación de Git
Si lo ha gitinstalado (requiere git v1.7.10 +):

clona este repositorio en la raíz de tu perfil de usuario
cd ~/ desde cualquier lugar entonces git clone https://github.com/nvm-sh/nvm.git .nvm
cd ~/.nvm y echa un vistazo a la última versión con git checkout v0.38.0
activarlo nvmobteniéndolo de su caparazón:. ./nvm.sh
Ahora agregue estas líneas a su ~/.bashrc, ~/.profileo ~/.zshrcarchivo para que se lo procedente automáticamente en el momento de inicio de sesión: (puede que tenga que añadir a más de uno de los archivos anteriores)

exportar NVM_DIR = " $ HOME /.nvm " 
[ -s  " $ NVM_DIR /nvm.sh " ] &&  \.  " $ NVM_DIR /nvm.sh "   # Esto carga nvm 
[ -s  " $ NVM_DIR / bash_completion " ] &&  \.  " $ NVM_DIR / bash_completion "   # Esto carga nvm bash_completion
Manual de instalación
Para una instalación completamente manual, ejecute las siguientes líneas para clonar primero el nvmrepositorio $HOME/.nvmy luego cargue nvm:

exportar NVM_DIR = " $ HOME /.nvm "  && (
  git clone https://github.com/nvm-sh/nvm.git " $ NVM_DIR "
   cd  " $ NVM_DIR " 
  git checkout ` git describe --abbrev = 0 --tags --match " v [0-9] * "  $ ( git rev-list --tags --max-count = 1 ) ` 
) &&  \.  " $ NVM_DIR /nvm.sh "
Ahora agregue estas líneas a su ~/.bashrc, ~/.profileo ~/.zshrcarchivo para que se lo procedente automáticamente en el momento de inicio de sesión: (puede que tenga que añadir a más de uno de los archivos anteriores)

exportar NVM_DIR = " $ HOME /.nvm " 
[ -s  " $ NVM_DIR /nvm.sh " ] &&  \.  " $ NVM_DIR /nvm.sh "  # Esto carga nvm
Actualización manual
Para la actualización manual con git(requiere git v1.7.10 +):

cambiar a la $NVM_DIR
desplegar los últimos cambios
echa un vistazo a la última versión
activar la nueva versión
(
   cd  " $ NVM_DIR "
  git fetch: origen de las etiquetas
  git checkout ` git describe --abbrev = 0 --tags --match " v [0-9] * "  $ ( git rev-list --tags --max-count = 1 ) ` 
) &&  \.  " $ NVM_DIR /nvm.sh "
Uso
Para descargar, compilar e instalar la última versión de node, haga lo siguiente:

nvm install node # "node" es un alias para la última versión
Para instalar una versión específica de nodo:

nvm install 6.14.4 # o 10.10.0, 8.9.1, etc.
La primera versión instalada se convierte en la predeterminada. Los nuevos shells comenzarán con la versión predeterminada del nodo (por ejemplo, nvm alias default).

Puede enumerar las versiones disponibles usando ls-remote:

nvm ls-remote
Y luego, en cualquier shell nuevo, simplemente use la versión instalada:

nodo de uso nvm
O simplemente puede ejecutarlo:

nvm ejecutar nodo --versión
O puede ejecutar cualquier comando arbitrario en una subcapa con la versión deseada del nodo:

nvm exec 4.2 nodo --versión
También puede obtener la ruta al ejecutable donde se instaló:

nvm que 5.0
En lugar de un puntero de versiones como "0,10" o "5.0" o "4.2.1", puede utilizar los siguientes alias predeterminados especiales con nvm install, nvm use, nvm run, nvm exec, nvm which, etc:

node: esto instala la última versión de node
iojs: esto instala la última versión de io.js
stable: este alias está obsoleto y solo se aplica realmente a node v0.12y antes. Actualmente, este es un alias para node.
unstable: este alias apunta a node v0.11: la última versión de nodo "inestable", desde la versión posterior a 1.0, todas las versiones de nodo son estables. (en SemVer, las versiones comunican rotura, no estabilidad).
Soporte a largo plazo
El nodo tiene una programación para soporte a largo plazo (LTS). Puede hacer referencia a versiones de LTS en alias y .nvmrcarchivos con la notación lts/*para el último LTS y lts/argonpara las versiones de LTS de la línea "argón", por ejemplo. Además, los siguientes comandos admiten argumentos LTS:

nvm install --lts/ nvm install --lts=argon/ nvm install 'lts/*'/nvm install lts/argon
nvm uninstall --lts/ nvm uninstall --lts=argon/ nvm uninstall 'lts/*'/nvm uninstall lts/argon
nvm use --lts/ nvm use --lts=argon/ nvm use 'lts/*'/nvm use lts/argon
nvm exec --lts/ nvm exec --lts=argon/ nvm exec 'lts/*'/nvm exec lts/argon
nvm run --lts/ nvm run --lts=argon/ nvm run 'lts/*'/nvm run lts/argon
nvm ls-remote --lts/ nvm ls-remote --lts=argon nvm ls-remote 'lts/*'/nvm ls-remote lts/argon
nvm version-remote --lts/ nvm version-remote --lts=argon/ nvm version-remote 'lts/*'/nvm version-remote lts/argon
Cada vez que su copia local de se nvmconecte a https://nodejs.org , volverá a crear los alias locales apropiados para todas las líneas LTS disponibles. Estos alias (almacenados en $NVM_DIR/alias/lts) son administrados por nvm, y no debe modificar, eliminar o crear estos archivos; espere que sus cambios se deshagan y espere que la intromisión en estos archivos cause errores que probablemente no serán compatibles.

Para obtener la última versión LTS del nodo y migrar sus paquetes instalados existentes, use

nvm install ' lts / * ' --reinstall-packages-from = current
Migración de paquetes globales durante la instalación
Si desea instalar una nueva versión de Node.js y migrar paquetes npm de una versión anterior:

nvm install node --reinstall-packages-from = nodo
Esto primero usará el "nodo de la versión nvm" para identificar la versión actual desde la que está migrando los paquetes. Luego resuelve la nueva versión para instalar desde el servidor remoto y la instala. Por último, ejecuta "nvm reinstall-packages" para reinstalar los paquetes npm de su versión anterior de Node a la nueva.

También puede instalar y migrar paquetes npm desde versiones específicas de Node como este:

nvm install 6 --reinstall-packages-from = 5
nvm install v4.2 --reinstall-packages-from = iojs
Tenga en cuenta que la reinstalación de paquetes no actualiza explícitamente la versión de npm ; esto es para garantizar que npm no se actualice accidentalmente a una versión rota para la nueva versión de nodo.

Para actualizar npm al mismo tiempo, agregue la --latest-npmbandera, así:

nvm install ' lts / * ' --reinstall-packages-from = default --latest-npm
o, en cualquier momento, puede ejecutar el siguiente comando para obtener la última versión de npm compatible en la versión actual del nodo:

nvm install-latest-npm
Si ya ha recibido un error en el sentido de "npm no admite Node.js", deberá (1) volver a una versión de nodo anterior ( nvm ls& nvm use <your latest _working_ version from the ls>, (2) eliminar la versión de nodo recién creada ( nvm uninstall <your _broken_ version of node from the ls>) , luego (3) vuelva a ejecutar su nvm installcon la --latest-npmbandera.

Paquetes globales predeterminados desde archivo durante la instalación
Si tiene una lista de paquetes predeterminados que desea instalar cada vez que instala una nueva versión, también lo admitimos; simplemente agregue los nombres de los paquetes, uno por línea, al archivo $NVM_DIR/default-packages. Puede agregar cualquier cosa que npm acepte como argumento de paquete en la línea de comando.

# $ NVM_DIR / paquetes-predeterminados

Rimraf
object-inspect@1.0.2
stevemao / pad izquierdo
io.js
Si desea instalar io.js :

nvm instalar iojs
Si desea instalar una nueva versión de io.js y migrar los paquetes npm de una versión anterior:

nvm install iojs --reinstall-packages-from = iojs
Las mismas pautas mencionadas para migrar paquetes npm en el nodo se aplican a io.js.

Versión del sistema del nodo
Si desea utilizar la versión de nodo instalada en el sistema, puede utilizar el alias predeterminado especial "sistema":

sistema de uso nvm
nvm run system --version
Listado de versiones
Si desea ver qué versiones están instaladas:

nvm ls
Si desea ver qué versiones están disponibles para instalar:

nvm ls-remote
Configuración de colores personalizados
Puede configurar cinco colores que se utilizarán para mostrar información de versión y alias. Estos colores reemplazan los colores predeterminados. Los colores iniciales son: gbyre

Códigos de color:

r/R = red / bold red

g/G = green / bold green

b/B = blue / bold blue

c/C = cyan / bold cyan

m/M = magenta / bold magenta

y/Y = yellow / bold yellow

k/K = black / bold black

e/W = light grey / white
nvm set-colors rgBcm
Colores personalizados persistentes
Si desea que los colores personalizados persistan después de terminar el shell, exporte la variable NVM_COLORS en su perfil de shell. Por ejemplo, si desea utilizar cian, magenta, verde, rojo intenso y amarillo intenso, agregue la siguiente línea:

exportar NVM_COLORS = ' cmgRY '
Suprimir la salida coloreada
nvm help (or -h or --help), nvm ls, nvm ls-remoteY nvm aliasgeneralmente producir una salida coloreada. Puede deshabilitar los colores con la --no-colorsopción (o configurando la variable de entorno TERM=dumb):

nvm ls --no-colors
nvm help --no-colors
TERM = tonto nvm ls
Restaurando PATH
Para restaurar su PATH, puede desactivarlo:

nvm desactivar
Establecer la versión de nodo predeterminada
Para establecer una versión de nodo predeterminada que se usará en cualquier shell nuevo, use el alias 'predeterminado':

nodo predeterminado de alias nvm
Usa un espejo de binarios de nodos
Para usar un espejo de los binarios del nodo, establezca $NVM_NODEJS_ORG_MIRROR:

exportar NVM_NODEJS_ORG_MIRROR = https: //nodejs.org/dist
nodo de instalación nvm

NVM_NODEJS_ORG_MIRROR = https: //nodejs.org/dist nvm install 4.2
Para usar un espejo de los binarios de io.js, establezca $NVM_IOJS_ORG_MIRROR:

exportar NVM_IOJS_ORG_MIRROR = https: //iojs.org/dist
nvm instalar iojs-v1.0.3

NVM_IOJS_ORG_MIRROR = https: //iojs.org/dist nvm instalar iojs-v1.0.3
nvm useno creará, de forma predeterminada, un enlace simbólico "actual". Establézcalo $NVM_SYMLINK_CURRENTen "true" para habilitar este comportamiento, que a veces es útil para los IDE. Tenga nvmen cuenta que el uso de varias pestañas de shell con esta variable de entorno habilitada puede provocar condiciones de carrera.

.nvmrc
Puede crear un .nvmrcarchivo que contenga un número de versión de nodo (o cualquier otra cadena que nvmcomprenda; consulte los nvm --helpdetalles) en el directorio raíz del proyecto (o en cualquier directorio principal). Posteriormente, nvm use, nvm install, nvm exec, nvm run, y nvm whichutilizará la versión especificada en el .nvmrcarchivo si no hay ninguna versión se suministra en la línea de comandos.

Por ejemplo, para que nvm adopte de forma predeterminada la última versión 5.9, la última versión de LTS o la última versión de nodo para el directorio actual:

$ echo  " 5.9 "  > .nvmrc

$ echo  " lts / * "  > .nvmrc # por defecto a la última versión de LTS

$ echo  " node "  > .nvmrc # por defecto a la última versión
[Nota: estos ejemplos asumen una versión de shell compatible con POSIX de echo. Si utiliza un entorno de cmddesarrollo de Windows , por ejemplo, el .nvmrcarchivo se utiliza para configurar una implementación remota de Linux, tenga en cuenta que los "mensajes de correo electrónico se copiarán y generarán un archivo no válido. Eliminarlos.]

Luego, cuando ejecuta nvm:

$ nvm use
Se encontró ' /path/to/project/.nvmrc ' con la versión < 5. 9> 
Ahora usando el nodo v5.9.1 (npm v3.7.3)
nvm useet. Alabama. recorrerá la estructura del directorio hacia arriba desde el directorio actual en busca del .nvmrcarchivo. En otras palabras, ejecutar nvm useet. Alabama. en cualquier subdirectorio de un directorio con un .nvmrcresultado en que .nvmrcse utiliza.

El contenido de un .nvmrcarchivo debe ser <version>(como se describe por nvm --help) seguido de una nueva línea. No se permiten espacios finales y se requiere la nueva línea final.

Integración más profunda de Shell
Puede utilizar avnpara integrarse profundamente en su shell e invocar automáticamente nvmal cambiar de directorio. noavn es compatible con el equipo de desarrollo. Por favor, informar de los problemas al equipo .nvmavn

Si prefiere una solución más liviana, los nvmusuarios han contribuido con las recetas a continuación . Están no soportadas por el nvmequipo de desarrollo. Sin embargo, estamos aceptando solicitudes de extracción para obtener más ejemplos.

intento
Llamar automáticamente nvm use
Ponga lo siguiente al final de su $HOME/.bashrc:

cdnvm () {
     cd  " $ @ " ; 
    nvm_path = $ ( nvm_find_up .nvmrc | tr -d ' \ n ' )

    # Si no hay un archivo .nvmrc, use la versión predeterminada de nvm 
    si [[ !  $ nvm_path  =  * [^ [: espacio:]] * ]] ;  luego

        declare default_version ; 
        default_version = $ ( versión nvm predeterminada ) ;

        # Si no hay una versión predeterminada, configúrela en `node` 
        # Esto usará la última versión en su máquina 
        si [[ $ default_version  ==  " N / A " ]] ;  luego 
            nvm alias nodo predeterminado ; 
            default_version = $ ( versión nvm predeterminada ) ; 
        fi

        # Si la versión actual no es la versión predeterminada, configúrela para usar la versión predeterminada 
        si [[ $ ( nvm current )  ! =  " $ Default_version " ]] ;  luego 
            nvm use default ; 
        fi

        elif [[ -s  $ ruta_nvm /.nvmrc &&  -r  $ ruta_nvm /.nvmrc]] ;  luego 
        declare nvm_version
        nvm_version = $ ( < " $ nvm_path " /.nvmrc )

        declare local_resolved_nvm_version
         # `nvm ls` comprobará todas las versiones disponibles localmente 
        # Si hay varias versiones coincidentes, tome la última 
        # Elimina los caracteres y espacios` -> 
        `y` * `y los espacios # ` local_resolved_nvm_version` será `N / A `si no se encuentran versiones locales 
        local_resolved_nvm_version = $ ( nvm ls --no-colors " $ nvm_version "  | tail -1 | tr -d ' \ -> * '  | tr -d ' [: space:] ' )

        # Si aún no está instalado, instálelo 
        # `nvm install` usará implícitamente la versión recién instalada 
        si [[ " $ local_resolved_nvm_version "  ==  " N / A " ]] ;  luego 
            nvm install " $ nvm_version " ; 
        elif [[ $ ( nvm current )  ! =  " $ local_resolved_nvm_version " ]] ;  luego 
            nvm usa " $ nvm_version " ; 
        fi 
    fi
}
alias cd = ' cdnvm '
 cd  $ PWD
Este alias buscaría "hacia arriba" en su directorio actual para detectar un .nvmrcarchivo. Si lo encuentra, cambiará a esa versión; de lo contrario, utilizará la versión predeterminada.

zsh
Llamar nvm useautomáticamente en un directorio con un .nvmrcarchivo
Ponga esto en su $HOME/.zshrcllamada para llamar nvm useautomáticamente cada vez que ingrese a un directorio que contiene un .nvmrcarchivo con una cadena que le dice a nvm a qué nodo use:

# ¡ Coloque esto después de la inicialización de nvm!
autoload -U add-zsh-hook
load-nvmrc () {
   local node_version = " $ ( versión nvm ) "
   local nvmrc_path = " $ ( nvm_find_nvmrc ) "

  if [ -n  " $ nvmrc_path " ] ;  luego 
    local nvmrc_node_version = $ ( nvm versión " $ ( cat " $ {nvmrc_path} " ) " )

    si [ " $ nvmrc_node_version "  =  " N / A " ] ;  luego
      instalar nvm
    elif [ " $ nvmrc_node_version "  ! =  " $ node_version " ] ;  luego
      uso de NVM
    fi 
  elif [ " $ node_version "  ! =  " $ ( nvm version default ) " ] ;  luego 
    repita  " Volviendo a la versión predeterminada de nvm "
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
pescado
Llamar nvm useautomáticamente en un directorio con un .nvmrcarchivo
Esto requiere que tengas el bajo instalado.

# ~ / .config / fish / functions / nvm.fish 
function nvm
  fuente de graves ~ / .nvm / nvm. sh  --no uso  ' ; ' nvm $ argv 
end

# ~ / .Config / pescado / funciones / nvm_find_nvmrc.fish 
función nvm_find_nvmrc
  fuente de graves ~ / .nvm / nvm. sh  --no uso  ' ; ' nvm_find_nvmrc
 end

# ~ / .config / fish / functions / load_nvm.fish 
function load_nvm --on-variable = " PWD "
   set  -l default_node_version (nvm version default)
   set  -l node_version (nvm version)
   set  -l nvmrc_path (nvm_find_nvmrc)
   if  test  -n  " $ nvmrc_path "
     conjunto  -l nvmrc_node_version (nvm versión ( cat  $ nvmrc_path ))
     si  prueba  " $ nvmrc_node_version " = " N / A " 
      nvm install (cat  $ nvmrc_path )
     else  if  prueba nvmrc_node_version! = node_version
      nvm use $ nvmrc_node_version 
    end 
  else  if  test  " $ node_version " ! = " $ default_node_version "
     echo  " Volviendo a la versión predeterminada del nodo "
    nvm use default
  fin 
fin

# ~ / .config / fish / config.fish 
# Debe llamarlo en la inicialización o escuchar el cambio de directorio no funcionará 
load_nvm
Licencia
nvm se publica bajo la licencia MIT.

Copyright (C) 2010 Tim Caswell y Jordan Harband

Por la presente se otorga permiso, sin cargo, a cualquier persona que obtenga una copia de este software y los archivos de documentación asociados (el "Software"), para operar con el Software sin restricciones, incluidos, entre otros, los derechos de uso, copia, modificación, fusión , publicar, distribuir, sublicenciar y / o vender copias del Software, y permitir que las personas a las que se les proporcione el Software lo hagan, sujeto a las siguientes condiciones:

El aviso de copyright anterior y este aviso de permiso se incluirán en todas las copias o partes sustanciales del Software.

EL SOFTWARE SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO, PERO NO LIMITADO A, LAS GARANTÍAS DE COMERCIABILIDAD, APTITUD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O TITULARES DE LOS DERECHOS DE AUTOR SERÁN RESPONSABLES DE CUALQUIER RECLAMO, DAÑOS U OTRA RESPONSABILIDAD, YA SEA EN UNA ACCIÓN DE CONTRATO, AGRAVIO O DE OTRO MODO, QUE SURJA DE, FUERA DE O EN RELACIÓN CON EL SOFTWARE O EL USO U OTRAS NEGOCIACIONES EN EL SOFTWARE.

Ejecución de pruebas
Las pruebas están escritas en Urchin . Instale Urchin (y otras dependencias) así:

npm install
Hay pruebas lentas y rápidas. Las pruebas lentas hacen cosas como instalar el nodo y verificar que se usen las versiones correctas. Las pruebas rápidas falsifican esto para probar cosas como los alias y la desinstalación. Desde la raíz del repositorio nvm git, ejecute las pruebas rápidas como esta:

npm run test/fast
Ejecute las pruebas lentas como esta:

npm run test/slow
Ejecute todas las pruebas como esta:

npm test
Nota bene: Evite ejecutar nvm mientras se ejecutan las pruebas.

Variables de entorno
nvm expone las siguientes variables de entorno:

NVM_DIR - directorio de instalación de nvm.
NVM_BIN - donde se instalan los paquetes de nodo, npm y globales para la versión activa de nodo.
NVM_INC - directorio de archivos de inclusión del nodo (útil para crear complementos C / C ++ para el nodo).
NVM_CD_FLAGS - utilizado para mantener la compatibilidad con zsh.
NVM_RC_VERSION - versión del archivo .nvmrc si se está utilizando.
Además, nvm modifica PATHy, si está presente, MANPATHy NODE_PATHal cambiar versiones.

Finalización de Bash
Para activar, necesita fuente bash_completion:

[[ -r  $ NVM_DIR / bash_completion]] &&  \.  $ NVM_DIR / bash_completion
Coloque la línea de abastecimiento anterior justo debajo de la línea de abastecimiento de nvm en su perfil ( .bashrc, .bash_profile).

Uso
nvm:

$ nvm Tab

alias               deactivate          install             list-remote         reinstall-packages  uninstall           version
cache               exec                install-latest-npm  ls                  run                 unload              version-remote
current             help                list                ls-remote           unalias             use                 which
alias de nvm:

$ nvm alias Tab

default      iojs         lts/*        lts/argon    lts/boron    lts/carbon   lts/dubnium  lts/erbium   node         stable       unstable
$ nvm alias my_alias Tab

v10.22.0       v12.18.3      v14.8.0
uso de NVM:

$ nvm use Tab

my_alias        default        v10.22.0       v12.18.3      v14.8.0
desinstalación de nvm:

Desinstalación de $ nvm Tab

my_alias        default        v10.22.0       v12.18.3      v14.8.0
Problemas de compatibilidad
nvmencontrará algunos problemas si tiene una configuración no predeterminada. (vea el n . ° 606 ) Se sabe que lo siguiente causa problemas:

En el interior ~/.npmrc:

prefijo = ' alguna / ruta '
Variables de entorno:

$ NPM_CONFIG_PREFIX 
$ PREFIX
Configuración de Shell:

set -e
Instalación de nvm en Alpine Linux
In order to provide the best performance (and other optimisations), nvm will download and install pre-compiled binaries for Node (and npm) when you run nvm install X. The Node project compiles, tests and hosts/provides these pre-compiled binaries which are built for mainstream/traditional Linux distributions (such as Debian, Ubuntu, CentOS, RedHat et al).

Alpine Linux, unlike mainstream/traditional Linux distributions, is based on BusyBox, a very compact (~5MB) Linux distribution. BusyBox (and thus Alpine Linux) uses a different C/C++ stack to most mainstream/traditional Linux distributions - musl. This makes binary programs built for such mainstream/traditional incompatible with Alpine Linux, thus we cannot simply nvm install X on Alpine Linux and expect the downloaded binary to run correctly - you'll likely see "...does not exist" errors if you try that.

There is a -s flag for nvm install which requests nvm download Node source and compile it locally.

If installing nvm on Alpine Linux is still what you want or need to do, you should be able to achieve this by running the following from you Alpine Linux shell:

apk add -U curl bash ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
The Node project has some desire but no concrete plans (due to the overheads of building, testing and support) to offer Alpine-compatible binaries.

As a potential alternative, @mhart (a Node contributor) has some Docker images for Alpine Linux with Node and optionally, npm, pre-installed.


Uninstalling / Removal
Manual Uninstall
To remove nvm manually, execute the following:

$ rm -rf "$NVM_DIR"
Edit ~/.bashrc (or other shell resource config) and remove the lines below:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion
Docker For Development Environment
To make the development and testing work easier, we have a Dockerfile for development usage, which is based on Ubuntu 14.04 base image, prepared with essential and useful tools for nvm development, to build the docker image of the environment, run the docker command at the root of nvm repository:

$ docker build -t nvm-dev .
This will package your current nvm repository with our pre-defined development environment into a docker image named nvm-dev, once it's built with success, validate your image via docker images:

$ docker images

REPOSITORY         TAG                 IMAGE ID            CREATED             SIZE
nvm-dev            latest              9ca4c57a97d8        7 days ago          650 MB
If you got no error message, now you can easily involve in:

$ docker run -h nvm-dev -it nvm-dev

nvm@nvm-dev:~/.nvm$
Please note that it'll take about 8 minutes to build the image and the image size would be about 650MB, so it's not suitable for production usage.

For more information and documentation about docker, please refer to its official website:

https://www.docker.com/
https://docs.docker.com/
Problems
If you try to install a node version and the installation fails, be sure to run nvm cache clear to delete cached node downloads, or you might get an error like the following:

curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.

Where's my sudo node? Check out #43

After the v0.8.6 release of node, nvm tries to install from binary packages. But in some systems, the official binary packages don't work due to incompatibility of shared libs. In such cases, use -s option to force install from source:

nvm install -s 0.8.6
If setting the default alias does not establish the node version in new shells (i.e. nvm current yields system), ensure that the system's node PATH is set before the nvm.sh source line in your shell profile (see #658)
macOS Troubleshooting
nvm node version not found in vim shell

If you set node version to a version other than your system node version nvm use 6.2.1 and open vim and run :!node -v you should see v6.2.1 if you see your system version v0.12.7. You need to run:

sudo chmod ugo-x /usr/libexec/path_helper
More on this issue in dotphiles/dotzsh.

nvm is not compatible with the npm config "prefix" option

Some solutions for this issue can be found here

There is one more edge case causing this issue, and that's a mismatch between the $HOME path and the user's home directory's actual name.

You have to make sure that the user directory name in $HOME and the user directory name you'd see from running ls /Users/ are capitalized the same way (See this issue).

To change the user directory and/or account name follow the instructions here

Homebrew makes zsh directories unsecure

zsh compinit: insecure directories, run compaudit for list.
Ignore insecure directories and continue [y] or abort compinit [n]? y
Homebrew causes insecure directories like /usr/local/share/zsh/site-functions and /usr/local/share/zsh. This is not an nvm problem - it is a homebrew problem. Refer here for some solutions related to the issue.

Macs with M1 chip

January 2021: there are no pre-compiled NodeJS binaries for versions prior to 15.x for Apple's new M1 chip (arm64 architecture).

Some issues you may encounter:

using nvm to install, say, v14.15.4:
the C code compiles successfully
but crashes with an out of memory error when used
increasing the memory available to node still produces the out of memory errors:
$ NODE_OPTIONS="--max-old-space-size=4096" ./node_modules/.bin/your_node_package
when using nvm to install some versions, the compilation fails
One solution to this issue is to change the architecture of your shell from arm64 to x86.

Let's assume that:

you already have versions 12.20.1 and 14.15.4 installed using nvm
the current version in use is 14.15.4
you are using the zsh shell
you have Rosetta 2 installed (macOS prompts you to install Rosetta 2 the first time you open a Intel-only non-command-line application, or you may install Rosetta 2 from the command line with softwareupdate --install-rosetta)
# Check what version you're running:
$ node --version
v14.15.4
# Check architecture of the `node` binary:
$ node -p process.arch
arm64
# This confirms that the arch is for the M1 chip, which is causing the problems.
# So we need to uninstall it.
# We can't uninstall the version we are currently using, so switch to another version:
$ nvm install v12.20.1
# Now uninstall the version we want to replace:
$ nvm uninstall v14.15.4
# Launch a new zsh process under the 64-bit X86 architecture:
$ arch -x86_64 zsh
# Install node using nvm. This should download the precompiled x64 binary:
$ nvm install v14.15.4
# Now check that the architecture is correct:
$ node -p process.arch
x64
# It is now safe to return to the arm64 zsh process:
$ exit
# We're back to a native shell:
$ arch
arm64
# And the new version is now available to use:
