/**
 *Created by Mikael Lindahl on 2022-04-29
 */
 
const debug = require('debug')

 const useDebug = (msg:string)=>{
  
    return debug(`react-django-postgres:frontend-react:components:{${msg}`)
 }
 
 export default useDebug