-------------- Table of Contents -------------------------
-- General Information.
-- Format.
-- Comments.
-- Simple Datatypes and Scopes.
-- Reading and Writing, io.write(true literal), io.read(), print().
-- Operators in lua including concatenation.
-- Conditional statements/constructs [if-elseif-else].
-- Looping statements/constructs [for, repeat, while].
-- Tables in Lua.
-- Metatables and metamethods.

-----------------------------------------------------------

-------- General Information ----------
-- Dynamically typed.
-- JIT - Lua JIT.
-- High-level language.
-- File Extension: .lua
-- Official website @ https://lua.org
-- Official Documentation/Reference @ https://www.lua.org/manual/

-----------------------------------------------------------

-------- Comments ----------
-- Single line comments.

-- Multi-line comments.
-- [[
-- Wow!
-- An amazing multi line comment. Probably one of the best of any programming lang.
-- ]]

-----------------------------------------------------------

-------- Simple Datatypes, Scopes ----------
--- Conventions
-- Global variables in camelCase or CAPS.

--- Syntax and Examples.
-- Global variables must be initialized.
-- Local variables can be just declared.
-- Variables by default have global scope.

simpleGlobalVar = 42 -- A global variable.
local local_var = 3 -- A local variable.

-- Datatypes
local int = 3 -- integer.
local boolean = false -- boolean
local float = 100.3 -- float.
local char = "c" -- char(string).
local strng = "string" --- string<immutable>.
strng = "string" -- valid.
local string_mult_line = [[
A multi line string?
Amazing!
]]

strng = nil -- Lua is garbage collected.

-- Undefined variables return nil.
var_name = some_unknown_variable -- var_name has nil.

-- Note: nil and false evaluate to false, 0 and '' are treated as true.

-----------------------------------------------------------

-------- Reading and Writing ----------
-- io.write(true literal)
-- io.write() defaults to stdout.
-- io.write() doesn't append a \n by default, but, print() does{like in python}.
io.write("Interested in giving a input?\n") -- Escape characters supported.
local line = io.read() -- Defaults to stdin.

print("You just entered, " .. line) -- .. is used for concatenation.

-----------------------------------------------------------

-------- Opeartors ----------
-- Assignment [ = ]
-- Doesn't support short-hand assignments { += ++ }
Var = 3
-- Relational [ == ~= < <= >= > ]
if Var ~= 10 then
	print("Var not equal to 10")
end
-- Bitwise
-- Ternary-Equivalent
ternary_evaluation = boolean and "yes" or "no" --> no.
-- Arithmetic Opeartors
local sum = float + int
print("Sum: " .. sum)

-- Logical [ and not or ]
-- 'or' and 'and' are short-circuted.

-----------------------------------------------------------

-------- Conditional statements ----------

if int > 30 then
	print("Over 30")
elseif strng ~= "this" then -- not equal to ~=. Strs can be compared in lua.
	io.write('string is not "this"\n') -- Defaults to stdout -- Defaults to stdout.
else
	print("Else body")
end

boolean_val = nil -- true / false in lua.

if not boolean_val then
	print("boolean_val evaluated to false")
end

-----------------------------------------------------------

-------- Looping statements ----------
-- Supports,
-- for, while, repeat

while local_var < 10 do
	local_var = local_var + 1 -- Doesn't support ++, += operators.
	print(local_var)
end

print()
for i = 0, 10 do -- Inclusive range.
	i = i + 1
	print(i) -- Prints from 1 to 11.
end

-- Format in general.
-- for variable = start, end[, jump] do body end
-- variable local by default.
print()
for i = 0, 10, 2 do
	print(i)
end

-- repeat
print("\nRepeat...")
local num = 10
repeat
	print(num)
	num = num - 1
until num == 0

-----------------------------------------------------------

-------- User Defined Functions ----------
print("\nUser Defined Functions Section")
-- [scope] function name(arg-list) body end
-- Returns, function calls, and assignments all work.
-- Functions can have mutliple return values.
-- No paranthesis function calls only work on literal string and literal-table parameter functions.
function fib(n)
	if n < 2 then
		return 1
	end
	return fib(n - 2) + fib(n - 1)
end

-- Closures and anonymous functions are supported.
local function adder(x)
	return function(y) -- You can't name the funtion here, "function as expression can't be named."
		return x + y
	end
end
-- Returned function is created when adder is called.
-- The value of x is remembered.

a1 = adder(9)
a2 = adder(36)
print(a1(16)) --> 25
print(a2(64)) --> 100

--- Lists
-- With lists that may be mismatched in length.
-- Unmatched receivers are nil;
-- unmatched senders are discarded.

x, y, z = 1, 2, 3, 4
-- Now x = 1, y = 2, z = 3, and 4 is thrown away.

function bar(a, b, c)
	print(a, b, c)
	return 4, 8, 15, 16, 23, 42
end

x, y = bar("zaphod") --> prints "zaphod  nil nil"
-- Now x = 4, y = 8, values 15...42 are discarded.

-- Functions are first-class, may be local/global.
-- These are the same:
function f(x)
	return x * x
end
f = function(x)
	return x * x
end

-- And so are these:
local function g(x)
	return math.sin(x)
end
local g
g = function(x)
	return math.sin(x)
end
-- the 'local g' decl makes g-self-references ok.

-- Trig funcs work in radians, by the way.

-- Calls with one string param don't need parens:
print("hello") -- Works fine.

-----------------------------------------------------------

-------- Tables ----------
-- Using tables like dictionaries

-- Dict literals have string keys by default.
-- String keys can use dot operators.
-- Strings and numbers are more portable keys.

emptyTable = {}
table = { key = "first_value", key_2 = "second_value", final_key = false }

-- #table i.e len(table) returns 0.
-- use pairs(table_name)

print("final_key: ", table.final_key) -- Prints the value associated with final_key.
table.newKey = {} -- Add a new key/value pair.
table.key_2 = nil -- Remove key_2 from the table.

-- Literal notation for any (non-nil) value as key.
a_table = { ["@!#"] = "qbert", [{}] = 1729, [6.28] = "value" }
print(a_table[6.28]) -- Prints 'value'
print(a_table[{}]) -- Prints nil.
-- Lookup fails since the key used is not
-- the same object as the one used to store the original value.

-- Key matching is basically by values for numbers and strings
-- By identity for tables.

-- One table-parameter function call needs no paranthesis.
function fun_name(x)
	print(table.key)
end
fun_name({ key = "foo" }) -- Prints 'foo'
fun_name({ key = "bar", key_2 = "baz" }) -- Prints 'bar'

for key, value in pairs(table) do
	print(key, value)
end

-- _G is a special table of all the globals.
print(_G["_G"] == _G) -- true.

-- Tables as lists/arrays.
-- List literals
list = {
	"this",
	"that",
	"them",
	true,
	3,
	10.3,
	function(name)
		print(name)
	end,
}

local list_len = #list

-- list indices start from 1!
for i = 1, list_len do
	print(list[i])
	if list[i] == true then
		print("Quitting since true was read.")
		break
	end
end

-- Lists are not a real type in Lua.
-- Lists are just tables with consecutive integer keys.
-- i.e list = {[1] = 'this', [2] = 'that', [3] = 'them', [4] = true, [5] = 3, [6] = 10.3}

-----------------------------------------------------------

print("\nMetatables and Metamethods")
-------- Metatables and metamethods ----------
-- {} + {} bad, if you aren't using metables.
-- Metatable is a table containing key value pairs, where keys are predefined functions,
-- that are invoked when a particular situation occurs. Values here are called 'metafunctions'
--[[
__add = function (arg-list)
          body
        return 
    end
--]]
-- Some metafunctions
-- __add()
-- __sub()
-- __div()
-- __unm()
-- __index()    for a.b
-- __tostring()
-- __pow()
-- __mod()      for a % b
-- __concate()  for a..b
-- __len()      for #a
-- __eq()
-- __lt()
-- __gt()
-- __le()       for a <= b
-- __newindex(a, b, c) for a.b = c
-- __call(a, ...)       for a(...)

local table = { 1, 2, 3 }

local metatable
metatable = {
	-- Giving a meaning to -table.
	__unm = function(list)
		-- If you manipulate list here, it is going to change the values in the same memory.
		-- So follow const correctness.
		local result = {}
		for i = 1, #list do
			result[i] = -list[i]
		end
		-- Return a reattached table.
		return setmetatable(result, metatable)
	end,
	-- Prints body of this function when you try to print a table.
	__tostring = function(list)
		local buffer = ""
		for i = 1, #list do
			buffer = buffer .. string.format("%d\n", list[i])
		end
		return buffer
	end,
}

setmetatable(table, metatable) -- Attaching the metatable to a table.
print(table) -- Prints the memory address, generally, using the __tostring metamethod.

local new_table = -table -- Invalid if you don't have a metatable.
print("Printing new table")
print(new_table)

new_table = -new_table -- Invalid if you don't reattach since, you are following const correctness.
print("We just revereted the table value back")
print(new_table)

local meta_of_table = getmetatable(table) -- Retrieve the metatable of 'table'.
for i, v in pairs(meta_of_table) do
	print(i, v) -- metafunction_name addr_of_function
end

-- __index on a metatable overloads dot lookups.
local def_favs = { city = "Zurich", food = "pizza" }
setmetatable(def_favs, { __index = { animal = "lion", place = "forest" } })
local myfavs = { food = "burger" }
setmetatable(myfavs, { __index = def_favs })
local eatenby = myfavs.animal -- works!
-- Looks for index animal in myfavs. Finds nothing, looks for animal in def_favs
-- At last, finds it in metatable of def_favs
print(eatenby) -- Prints lion.

print(myfavs.food) -- Prints burger.
-- Direct table lookups that fail will retry using the
-- table's metatable's __index value, and this recurses.
-- An __index value can also be a function(table, key) for customized lookups.

-----------------------------------------------------------
-------- Classes, Objects, and Object Oriented Programming ----------
-- Classes like tables and inheritence.
-- Classes must be built using tables and metatables.

print("\nImplementing class-like tables using metatables")
Dog = {} -- 1.

function Dog:new_dog() -- 2.
	local newObj = { sound = "woof" } -- 3.
	self.__index = self -- 4.
	-- Set the newObj tables metatable to Dog.
	return setmetatable(newObj, self) -- 5.
end

function Dog:makeSound() -- 6.
	print("I say " .. self.sound)
end

mrDog = Dog:new_dog() -- 7.
mrDog:makeSound() -- "I say woof" -- 8.

-- 1. Dog acts like a class, but really it's just a table.
-- 2. function tablename:fun(...) is same as
--      function tablename.fun(self, ...)
--      tablename.fun = function(self, ...)
--      : is just a syntactic sugar, it just adds the self arg.
--
-- 3. newObj will be an instance of the class Dog.
-- 4. self = the class being instantiated. Often
--      self = Dog, but inheritence can change it.
--      newObj gets self's functions when we set both
--      newObj's metable and self's __index to self.
-- 5. Reminder: setmetatable returns its first arg.
-- 6. The : works as in 2, but this time we expect
--      self to be an instance of instance instead of a class.
-- 7. Same as Dog.new(Dog), so self = Dog in new().
-- 8. Same as mrDog.makeSound(mrDog); self = mrDog.

------- Inheritence using tables and metatables.
LoudDog = Dog:new() -- 1.

function LoudDog:makeSound()
	s = self.sound .. " " -- 2.
	print(s .. s .. s)
end

wolf = LoudDog:new() -- 3.
wolf:makeSound() -- 'woof woof woof'    -- 4.

-- Hierarchy: Dog <= LoudDog <= wolf

-- 1. LoudDog gets Dog's methods and variables.
-- 2. self has a 'sound' key from new(), see 3.
-- 3. Same as LoudDog.new(LoudDog), and converted to
--      Dog.new(LoudDog) as LoudDog has no 'new' key <remember __index is recursive>,
--      but does have an __index = Dog on its metatable.
--      Result: wolf's metatable is LoudDog, and
--      LoudDog.__index = LoudDog. So wolf.key = wolf.key, LoudDog.key, Dog.key
--      whichever table is the first with the given key.
-- 4. The 'makeSound' key is found in LoudDog; this
--      is the same as LoudDog:makeSound(wolf).

-- If needed, a subclass's new() is like the base's:
function LoudDog:new()
	newObj = {}
	-- set up newObj
	self.__index = self
	return setmetatable(newObj, self)
end

--- Some examples of classes and inheritence.
--[[
  -- Main thing that allows inheritence and objects like behaviour.
  -- A metatables index value recurses.

    -- Base class
    -- Metatable and the table are the same.
    local animals
    animals = {
            -- __index = animals,           Doesn't work!
            name = "generic_animal",
            place = "generic_place",
            food = "generic_food",
    }

    animals.__index = animals
    --[[
        -- A metatable for animals table.
        local meta_animal = {
                __index = animals,
        }


    ----------------- Inheritence ---------------
  
    animals = {}

    animals.__index = animals
    function animals:display()
            print("I am " .. self.name)
    end

    fish = {}
    -- fish is the metatable for itself.
    fish.__index = fish
    -- Setting the parent of fish as animals.
    setmetatable(fish, animals)

    tuna = {}
    tuna.__index = tuna
    setmetatable(tuna, fish)
    function tuna:get(name)
            local instance = {}
            instance.name = name
            return setmetatable(instance, tuna)
    end

    function tuna:display()
            print("I am " .. self.name .. " in the tuna class")
    end

    -- Can access indices in animal also, since animals is the metatable for fish.
    fish1 = tuna:get("tuna")
    fish1:display() -- Displays the the display() in the immediate above metatable.
    -- Overriding.
--]]

-- Constructor for animals class.
function animals:new(name)
	-- Create an animal, and set it's name to the arg.
	local animal = { name = name }
	-- Return the table with animals reattached.
	return setmetatable(animal, animals)
	-- setmetatable returns its first arg.
end

-- setmetatable(animals, meta_animals)
-- If you are not able to find an index in animals, it will at it's metatable for the index implementation.

function animals:display()
	print("I am " .. self.name)
end

-- Creating a tiger animal i.e creating an instance.
tiger = animals.new(tiger, "tiger") -- Better, tiger = animals:new("tiger")  -- Passes self.
tiger:display()
-- Displays "I am generic_animal" since tiger has no field named name.

-- local cat = animals.new(tiger, "cat")
-- cat:display()
-- tiger:display()
-- Prints cat and tiger respectively.
-- Doesn't affect since the constructor doesn't use self.
--]]
-----------------------------------------------------------
-------- Modules ----------
--- Using the require keyword, you can use functionalities provided in other lua program.
--- require, dofile, loadfile, load.

--[[
-- In some_module.lua
  function greet(name)
    print("hello, ".. name)
  end

  local M = {}
  function M.trygreeting(name)
    print("Try greeting!")
    greet(name)
  end

  return M

-- In a different lua file,
  local module = require("some_module")

  -- Equivalent to saying...
  local module = (function some_module()
    local M = {}
    function M.greet(name)
      print("hello, ".. name)
    end
    return M
  end) ()
  --------------------------
 
  local name = io.read(name)
  module.trygreeting(name) -- valid.

  module.greet(name) -- Invalid. greet = nil.

  -- require's reutrn values are cached.
  -- so a file is only run once, even when require'd many times.
  -- Example:
    -- If mod.lua has 'print("hello")'
    local a = require('mod') -- Prints 'hello'.
    local b = require('mod') -- Prints nothing.
    print(a, b) -- true true
 
  -- dofile is like require without caching.
    dofile('mod.lua') -- Prints 'hello'
    dofile('mod.lua') -- Prints 'hello' (again)

  -- loadfile loads a lua file, but, doesn't run it.
  local f = loadfile('mod.lua') -- Prints nothing.
  f() -- Prints 'hello'
  f() -- Prints 'hello'

  -- load is the loadfile for strings.
  -- (loadstring) - depricated.
  local g = load('print(345)')
  g() -- Prints 345.
  g() -- Prints 345.

--]]
