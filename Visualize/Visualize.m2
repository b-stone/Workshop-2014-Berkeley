--------------------------------------------------------------------------
-- PURPOSE : Visualize package for Macaulay2 provides the ability to 
-- visualize various algebraic objects in java script using a 
-- modern browser.
--
-- Copyright (C) 2013 Branden Stone and Jim Vallandingham
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License version 2
-- as published by the Free Software Foundation.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--------------------------------------------------------------------------


newPackage(
	"Visualize",
    	Version => "0.2", 
    	Date => "October 2, 2013",
    	Authors => {       
	     {Name => "Elliot Korte", Email => "ek2872@bard.edu"},	     
	     {Name => "Will Smith", Email => "smithw12321@gmail.com"},		
	     {Name => "Branden Stone", Email => "bstone@bard.edu", HomePage => "http://www.bard.edu/~bstone/"},	     
	     {Name => "Jim Vallandingham", Email => "vlandham@gmail.com", HomePage => "http://vallandingham.me/"}
	     },
    	Headline => "Visualize",
    	DebuggingMode => true
    	)

export {
    
    -- Options
     "Path",
     "visTemplate",
    
    -- Methods
     "visIntegralClosure",
     "visIdeal",
     "visGraph",
     "runServer", --helper
     "toArray", --helper
     "getCurrPath" --helper
}

needsPackage"Graphs"


------------------------------------------------------------
-- METHODS
------------------------------------------------------------

-- Input: None.
-- Output: String containing current path.

getCurrPath = method()
installMethod(getCurrPath, () -> (local currPath; currPath = get "!pwd"; substring(currPath,0,(length currPath)-1)))


--input: A list of lists
--output: an array of arrays
--
-- would be nice if we could use this on any nesting of lists/seq
--
toArray = method() 
toArray(List) := L -> (
     return new Array from apply(L, i -> new Array from i);
     )
    


--input: A path
--output: runs a server for displaying objects
--
runServer = method(Options => {Path => getCurrPath()})
runServer(String) := opts -> (visPath) -> (
    return run visPath;
    )


--input: Three Stings. The first is a key word to look for.  The second
--    	 is what to replace the key word with. The third is the path 
--    	 where template file is located.
--output: A file with visKey replaced with visString.
--
visOutput = method(Options => {Path => getCurrPath()})
visOutput(String,String,String) := opts -> (visKey,visString,visTemplate) -> (
    local fileName; local openFile; local PATH;
    
    fileName = (toString currentTime() )|".html";
    PATH = opts.Path|fileName;
    openOut PATH << 
    	replace(visKey, visString , get visTemplate) << 
	close;
                  
    return show new URL from { "file://"|PATH };
    )



--input: A monomial ideal of a polynomial ring in 2 or 3 variables.
--output: The newton polytope of the of the ideal.
--
visIdeal = method(Options => {Path => "./", visTemplate => "./templates/visIdeal/visIdeal"})
visIdeal(Ideal) := opts -> J -> (
    local R; local arrayList; local arrayString; local numVar; local visTemp;
    
    R = ring J;
    numVar = rank source vars R;
    
    if ((numVar != 2) and (numVar != 3)) then (error "Ring needs to have either 2 or 3 variables.");
    
    if numVar == 2 
    then (
    	visTemp = opts.visTemplate|"2D.html";
	arrayList = apply( flatten entries gens J, m -> flatten exponents m);	
	arrayList = toArray arrayList;
	arrayString = toString arrayList;
    )
    else (
	visTemp = opts.visTemplate|"3D.html";
    	arrayList = apply(flatten entries basis(0,infinity, R/J), m -> flatten exponents m );
    	arrayList = toArray arrayList;
    	arrayString = toString arrayList;
    );
	
    return visOutput( "visArray", arrayString, visTemp, Path => opts.Path );
    )

--input: A monomial ideal of a polynomial ring in 2 or 3 variables.
--output: The newton polytope of the integral closure of the ideal.
--
visIntegralClosure = method(Options => {Path => getCurrPath(), visTemplate => getCurrPath() | "/templates/visIdeal/visIdeal.html"})
visIntegralClosure(Ideal) := opts -> J -> (
    local R; local arrayList; local arrayString; 
--    local fileName; local openFile;

    R = ring J;
    J = integralClosure J;
    arrayList = apply(flatten entries basis(0,infinity, R/J), m -> flatten exponents m );
    arrayList = toArray arrayList;
    arrayString = toString arrayList;
    
    return visOutput( "visArray", arrayString, opts.visTemplate, Path => opts.Path );

--    G = flatten entries mingens integralClosure J;
--    arrayList = new Array from apply(G, i -> new Array from flatten exponents i);
--    arrayString = toString arrayList;
    
--    return visOutput(arrayString, Path => opts.Path ); 
    )


--input: A graph
--output: the graph in the browswer
--
visGraph = method(Options => {Path => getCurrPath(), visTemplate => getCurrPath() | "/templates/visGraph/visGraph-template.html"})
visGraph(Graph) := opts -> G -> (
    local A; local arrayList; local arrayString;
    
    A = adjacencyMatrix G;
    arrayList = toArray entries A;
    arrayString = toString arrayList;
    
    return visOutput( "visArray", arrayString, opts.visTemplate, Path => opts.Path );
    )


--------------------------------------------------
-- DOCUMENTATION
--------------------------------------------------

-- use simple doc
beginDocumentation()

document {
     Key => Visualize,
     Headline => "A package to help visualize algebraic objects in the browser using javascript.",
     
     "Lots of cool stuff happens here.",
     
     PARA{}, "For the mathematical background see ",

     
     UL {
	  {"Winfried Bruns and Jürgen Herzog.", EM " Cohen-Macaulay Rings."},
	},
     
     }

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-----------------------------
-----------------------------
-- Stable Tests
-----------------------------
-----------------------------

restart
loadPackage"Graphs"
loadPackage"Visualize"

G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
visGraph( G, Path => getCurrPath()|"/temp-files/" )

R = QQ[x,y,z]
I = ideal"x4,xyz3,yz,xz,z6,y5"
visIdeal( I,  Path => getCurrPath()|"/temp-files/" )

-----------------------------
-----------------------------
-- Testing Ground
-----------------------------
-----------------------------

restart
loadPackage"Graphs"
loadPackage"Visualize"

R = QQ[x,y,z]
I = ideal"x4,xy6z,x2y3,z4,y8"
G = flatten entries mingens I
ExpList = apply(G, g -> flatten exponents g )
maxX = 0
maxY = 0
maxZ = 0
scan( ExpList, e -> ( 
	  if e#0 > maxX then maxX = e#0;
	  if e#1 > maxY then maxY = e#1;
	  if e#2 > maxZ then maxZ = e#2;
	  )
     )
maxX,maxY,maxZ

divZ = (G,i) -> select(G, g -> (g%z^(i+1) != 0) and (g%z^i == 0) )

data = {{0,0,0}}

L = sort divZ(G,0)
H = unique apply(#L-1, i -> flatten exponents lcm(L#i, L#(i+1) ) )
data = unique join(data, flatten apply(H, h -> toList({0,0,0}..h) ) )

L = sort join(divZ(G,1), apply(L, l -> l*z ) )
H = unique apply(#L-1, i -> flatten exponents lcm(L#i, L#(i+1) ) )
data = unique join(data, flatten apply(H, h -> toList({0,0,0}..h) ) )

L = sort join(divZ(G,2), apply(L, l -> l*z ) )
H = unique apply(#L-1, i -> flatten exponents lcm(L#i, L#(i+1) ) )
data = unique join(data, flatten apply(H, h -> toList({0,0,0}..h) ) )

L = sort join(divZ(G,3), apply(L, l -> l*z ) )
H = unique apply(#L-1, i -> flatten exponents lcm(L#i, L#(i+1) ) )
data = unique join(data, flatten apply(H, h -> toList({0,0,0}..h) ) )

L = sort join(divZ(G,4), apply(L, l -> l*z ) )
H = unique apply(#L-1, i -> flatten exponents lcm(L#i, L#(i+1) ) )
data = unique join(data, flatten apply(H, h -> toList({0,0,0}..h) ) )

new Array from apply(data, i -> new Array from i)




viewHelp basis
S = R/I
data = apply(flatten entries basis(0,infinity, R/I ), m -> flatten exponents m )
new Array from apply(data, i -> new Array from i)

lcm(L_1,L_2,L_3)
H = flatten flatten apply(#L, j -> apply(#L, i -> apply(L, l -> (l, L#i, L#j) ) ))
Hh = unique apply(H, h->  flatten exponents lcm h )
sort Hh

H2 = unique flatten apply(Hh, h -> toList({0,0,0}..h) )
Ll = new Array from apply(H2, i -> new Array from i)
sort H2
