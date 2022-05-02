/**
 *Created by Mikael Lindahl on 2022-04-29
 */


import React, {useState} from 'react';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome'
import {faTrashAlt, faEdit} from '@fortawesome/free-regular-svg-icons'
import UserDataItemEdit from "./UserDataItemEdit";
import UserDataItemDelete from "./UserDataItemDelete";
import {UserData} from "../../redux/slices/userDataSlice";
import styles from "./UserDataItem.module.scss"

type TProps = {
    item: UserData,
    onClick: (url: string) => void
}

const UserDataItem = (props: TProps) => {

    const [remove, setRemove] = useState(false)
    const [edit, setEdit] = useState(false)

    return (
        <div>
            <div className={'d-flex p-1'}>
                <div className={'flex-fill my-1 me-1'}>
                    <div>
                        <button className={'btn btn-secondary w-100 '+styles.button} onClick={() => {
                            props.onClick(props.item.url)
                        }
                        }>{props.item.name}</button>
                        <div className={'text-center'}>
                            <small className={'text-muted text-xs'}>{props.item.updated_at}</small>
                        </div>
                    </div>

                </div>
                <div className={'d-flex flex-column'}>
                    <div onClick={() => {
                        setEdit(true)
                        setRemove(false)
                    }}>
                        <FontAwesomeIcon icon={faEdit}/>
                    </div>
                    <div onClick={() => {
                        setRemove(true)
                        setEdit(false)
                    }}>
                        <FontAwesomeIcon icon={faTrashAlt}/>
                    </div>
                </div>

            </div>
            {edit && <UserDataItemEdit id={props.item.id}
                                       onClose={() => setEdit(false)}

            />}
            {remove && <UserDataItemDelete id={props.item.id}
                                           onClose={() => setRemove(false)}

            />}
        </div>
    )


}

export default UserDataItem