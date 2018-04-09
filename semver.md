# Node semantic version interpretation documentation
  
Node versions are dynamically interpretted from the semver expression that is extracted from the local package.json file. The algorithm for doing this is expressed below. Each step is isolated into its own function to make testing and debugging easier.
  
## 1. Extract the semver expression located in the engines.node value of the local package.json file.
  
#### Required input grammar for semver expression extracted from package.json:
  
> Grammar is copied from https://docs.npmjs.com/misc/semver
> ```
> range-set  ::= range ( logical-or range ) *
> logical-or ::= ( ' ' ) * '||' ( ' ' ) *
> range      ::= hyphen | simple ( ' ' simple ) * | ''
> hyphen     ::= partial ' - ' partial
> simple     ::= primitive | partial | tilde | caret
> primitive  ::= ( '<' | '>' | '>=' | '<=' | '=' | ) partial
> partial    ::= xr ( '.' xr ( '.' xr qualifier ? )? )?
> xr         ::= 'x' | 'X' | '*' | nr
> nr         ::= '0' | ['1'-'9'] ( ['0'-'9'] ) *
> tilde      ::= '~' partial
> caret      ::= '^' partial
> qualifier  ::= ( '-' pre )? ( '+' build )?
> pre        ::= parts
> build      ::= parts
> parts      ::= part ( '.' part ) *
> part       ::= nr | [-0-9A-Za-z]+
> ```
> Lazy grammar validation is used at this point. Basically any string in the engines.node value will be accepted at this point that matches the following regexp:  
> "[|<> [:alnum:].^=~*-]\+"  
> 
> NOTE: all whitespace inside the engines.node value is normalized to be a single space in this step.
  
## 2. Check that the extracted semver expression from the previous step matches the above grammar. If so, normalize it into the following grammar that is expected by the interpretation logic.
  
#### Required input grammar for internal interpretation logic:

> ```
> semver         ::= comparator_set ( ' || '  comparator_set )*
> comparator_set ::= comparator ( ' ' comparator )*
> comparator     ::= ( '<' | '<=' | '>' | '>=' | '' ) [0-9]+ '.' [0-9]+ '.' [0-9]+
> ```
  
## 3. Interpret the normalized semver expression.
  
> 1. Resolve each comparator set to the newest compatible node version
> - iterate through node versions from newest to oldest
> - find the first node version that satisfies all comparators
> - if reached a point where no older node versions will satisfy comparator, stop iterating through node versions.
> 2. Choose the newest node version among the resolved node versions from the previous step.
  
