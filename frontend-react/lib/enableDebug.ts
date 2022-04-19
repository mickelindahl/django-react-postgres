
import root from 'window-or-global'

/**
 * Add string to localStorage.debug to enable debugging messages in browser
 * when running locally
 *
 */
export default ()=>{

    if (root.location && root.location.protocol=='http:'){

        localStorage.debug='bk-manager*'

    }
}