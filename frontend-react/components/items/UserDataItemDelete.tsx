/**
 *Created by Mikael Lindahl on 2022-05-02
 */

import React, {useState} from 'react';
import {useAppDispatch} from "../../redux/hooks";
import url from "../../constants/url";

import {deleteUserData} from "../../redux/slices/userDataSlice";

type TProps = {
    id: number,
    onClose: () => void
}

const UserDataItemDelete = (props: TProps) => {

    const dispatch = useAppDispatch()

    const [error, setError] = useState(null)

    const onDelete = () => {

        fetch(
            url.FILE_UPLOAD + '/' + props.id,
            {method: 'DELETE'}
        )
            .then((response) => response.json())
            .then((result) => {

                if (result.error) {
                    throw result.error
                    // props.onError(result.error)
                    // console.error('Error:', result.error);
                    // return
                }

                dispatch(deleteUserData(props.id))
            })
            .catch((error) => {
                setError(error)
                console.error('Error:', error);
            });
    }

    return <div>
        <p className={'m-1'}>Are you sure you want to delete this entry?</p>
        <div className={'m-1'}>
            <button className={'btn btn-primary me-1'}
                    onClick={() => {
                        onDelete()
                        // setEditItemId(-1)
                    }}>Delete
            </button>
            <button className={'btn btn-danger'}
                    onClick={() => {
                        props.onClose()
                    }}>Close
            </button>
        </div>
        {error && <p className={'text-danger'}>File deletion failed!</p>}
    </div>

}

export default UserDataItemDelete