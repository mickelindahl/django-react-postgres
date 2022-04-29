/**
 *Created by Mikael Lindahl on 2022-04-29
 */

import React from 'react';

type TProps = {
    name:string,
    url:string,
    onClick:(url:string)=>void

}

const UserDataItem = (props:TProps) => {

    return <div className={'p-1'}>
            <button className={'btn btn-secondary w-100'} onClick={()=>{
                props.onClick(props.url)
            }
            }>{props.name}</button>
        </div>


}

export default UserDataItem