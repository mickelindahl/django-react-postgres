import React, {useState, useEffect} from "react";
import styles from "./DataProvider.module.scss";
import { useAppDispatch } from '../redux/hooks'
import {setUserData} from '../redux/slices/userDataSlice'
import useDebug from "../hooks/useDebug";
const debug = useDebug('components:DataProvider');

type TProps = {
    endpoint: string,
    render: () => React.ReactElement
}

/**
 *
 * Wrapper for fetching data on page load
 *
 */
const DataProvider = (props: TProps) => {

    const [loaded, setLoaded] = useState(false)
    const [placeholder, setPlaceholder] = useState('Loading ...')
    const dispatch = useAppDispatch()

    useEffect(() => {
        fetch(props.endpoint)
            .then(res => res.json())
            .then(data => {

                dispatch(setUserData(data.userData))
                setLoaded(true)

            })
            .catch(error => {
                setPlaceholder("Something went wrong")
                console.log(error)
            });
    })


    // const {data, loaded, placeholder, storage} = this.state;
    return loaded ? props.render() :
        <div className={styles['data-provider']}><p>{placeholder}</p></div>;

}

export default DataProvider;