Panthro: the rubygems proxy/cache
=================================

Los inicios: 2014~2015
======================

Empecé este proyecto en el año 2014, cuando arranqué lo hice por dos motivos
principales: el primero era ver si podía acelerar la instalación de gemas por que
estaba trabajando en proyecto en particular que requeria hacer pruebas y esas
pruebas incluían la instalación de gemas repetidas veces, entonces necesitaba
acelear ese proceso. Pensé que podía hacer una especie de proxy para rubygems
usando rack y además me parecía una muy buena idea para aprender y jugar.
En ese momento en 2014-2015 lo hice y funcionó, de una forma muy rudimentaría
y cona varios defectos, pero funcionaba y cumplía con el propósito.
Así fué como publiqué la primer version de Panthro, un proxy/cache de gemas hecho en rack,
recuerdo que quedé sorprendido por la simplicidad de rack y por las cosas
que se pueden llegar a hacer, además había logrado acelerar la velocidad
de rubygemes (gem install) 4x, lo cual era mucho, estaba orgulloso :).
Lo que Pantrho hace es muy sencillo, cachea únicamente los archivos
de gemas es decir los .gem pero no las llamadas a la api y fue una decisión
acertada por que las dependendencias van camnbiando y los .gem no.

Así era la primer versión:

https://github.com/gramos/panthro/blob/v0.0.5/lib/panthro.rb

Hoy 10 años mas tarde 2024
===========================

Retomé este proyecto con el mismo objetivo que en el pasado, aprender
y divertirme, el primer día al probarlo por primera vez en 10 años
obviamente no funcionaba nada, así que me dediqué a hacerlo funcionar
con las versiones actuales de Ruby, Rack y Rubygems. En poco tiempo
lo logré y estaba andando luego de varios ajustes y cambios debidos
a la nueva api de rubygems, creo que esto me llevó 1 día quizás 2.
Una vez que lo hice funcionar lo empecé a testear/probar usando Rumb,
la gema para medir y comparar 2 mirrors de gems, bueno ahí fué cuando
me dí cuenta que funcionaba más lento que usar gem, sí! funciona más
lento! para mi sorpresa, no puedo entender completamente por qué sucede esto.
Voy a hacer una mini explicación de como funciona el comando gem install,
más que nada para mí, para ver si entender más como funciona me puede
ayudar a entender por qué pasa esto.

<pre>
gramos ~/svitla/panthro (3.3.4) [master] $ gem install cuba --verbose
HEAD http://localhost:9292/
200 OK
GET http://localhost:9292/info/cuba
200 OK
GET http://localhost:9292/quick/Marshal.4.8/cuba-4.0.3.gemspec.rz
200 OK
GET http://localhost:9292/info/contest
200 OK
GET http://localhost:9292/info/haml
200 OK
GET http://localhost:9292/info/rack
200 OK
GET http://localhost:9292/info/rack-session
200 OK
GET http://localhost:9292/info/rack-test
200 OK
GET http://localhost:9292/info/stories
200 OK
GET http://localhost:9292/info/tilt
200 OK
GET http://localhost:9292/info/webrat
200 OK
Downloading gem cuba-4.0.3.gem
GET http://localhost:9292/gems/cuba-4.0.3.gem
Fetching cuba-4.0.3.gem
200 OK
</pre>

Como podemos observar las primeras llamadas son:

<pre>
/info/cuba
/quick/Marshal.4.8/cuba-4.0.3.gemspec.rz
</pre>

/info/cuba trae información de todas las versiones de la gema consultada,
en este caso Cuba, en formato de texto plano. Para mayores
detalles podemos consultar la documentación

https://guides.rubygems.org/rubygems-org-compact-index-api/

luego de esto hace un request a la api para traerse el /info
de cada dependencia y finalmente se trae la gema y todas las
gemas de las que depende:

<pre>
GET http://localhost:9292/gems/cuba-4.0.3.gem
</pre>

Bueno, así es más o menos como trabaja "gem install",
ahora bien, podrímoas inferir entonces que si
Panthro cachea todos los gemspec.rz y los .gem
en el disco, entonces no los tiene que pedir al
server, al instalar una gema grande con muchas dependencias,
como rails por ejemplo, la instalación debería ser
mucho más rápida. Malas noticias...no es así,
en el pasado cuando hice la primer versión funcionaba
perefecto, pero ahora después de 10 años rubygems
ha mejorado mucho y es mucho más råpido que antes.
Dicho esto, no comprendo con exatitud por que
Pantrho no es mås råpido que rubygems. Por que
si Panthro cachea todos los archivos estáticos
y las llamadas a la api las redirije a rubygems.org
en la teoría debería ser más rápido a no ser que yo
me esté perdiendo de algo, lo cual es muy posible.

