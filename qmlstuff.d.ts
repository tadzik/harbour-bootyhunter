declare module Qt {
    function createComponent(filename: string) : any;
}

declare interface Component {
    // anchors
    top:    any;
    bottom: any;
    left:   any;
    right:  any;

    // size
    width:  number;
    height: number;

    // position
    x:      number;
    y:      number;

    visible: boolean;

    // methods
    destroy();
}

declare module LocalStorage {
    function openDatabaseSync(dbname: string, dbver: string,
                              dbdesc: string, dbsize: number,
                              dbconfig: Function) : Database;

}

declare interface Database {
    transaction(func: Function);
    changeVersion(v1: string, v2: string);
}
