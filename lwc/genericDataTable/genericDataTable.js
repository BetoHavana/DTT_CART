import { LightningElement, track, api } from 'lwc';

export default class GenericDataTable extends LightningElement {
    @api buttonLimit;

    @api genericcolumns;

    @api genericdata;

    @api genericdefaultsortdirection;

    @api genericerror;

    @api generichidecheckbox;

    @api generickey;

    @api genericsortedby;

    @api genericsorteddirection;

    @api messagewhennodata;

    @api noOfRecordsPerPage;

    @api showPagination;

    @api sortWithinPaginatedData = false;

    @track currentPage = 1;

    @track pageListToShow= [];

    @track paginatedData=[];

    hasNoRows = false;

    pageListFirst;

    pageListLast;

    pageNumberList = [];

    showFirstDot;

    showNextDot;

    renderedCallback() {
        this.addUnderline();
    }

    get paginateddatafetch() {
        let paginatedDatavalue;
        if (this.paginatedData.length > 0) {
            paginatedDatavalue = this.paginatedData;
        } else if (this.genericdata && this.showPagination) {
            paginatedDatavalue = this.processPaginationWithGenericMethod(this.genericdata);
            this.paginatedData = paginatedDatavalue;
        } else {
            paginatedDatavalue = this.genericdata;
            this.paginatedData = paginatedDatavalue;
        }
        return paginatedDatavalue;
    }

    set paginateddata(value) {
        if (this.paginatedData) {
            this.paginatedData = value;
        } else if (this.genericdata && this.showPagination) {
            this.paginatedData = this.processPaginationWithGenericMethod(this.genericdata);
        } else {
            this.paginatedData = this.genericdata;
        }
    }

    @api
    setDataOnSearch(value) {
        this.currentPage = 1;
        this.genericdata = value;
        this.paginatedData = this.processPaginationWithGenericMethod(value);
    }

    processPaginationWithGenericMethod(data) {
        if (data.length > 0) {
            const pageNumberArray = [];
            this.totalPagesToDisplay = Math.ceil(data.length / this.noOfRecordsPerPage);
            for (let index = 1; index <= this.totalPagesToDisplay; index++) {
                pageNumberArray.push(index);
            }
            this.pageNumberList = pageNumberArray;
            this.displayPageNumbers();
            this.hasNoRows = false;
        } else {
            this.totalPagesToDisplay = 0;
            this.pageNumberList = [];
            this.hasNoRows = true;
        }
        return data.slice(0, this.noOfRecordsPerPage);
    }

    displayPageNumbers() {
        let firstDot = false;
        let nextDot = false;
        const currentPageNumber = Number(this.currentPage);
        const buttonLimit = Number(this.buttonLimit);
        if (this.pageNumberList.length > currentPageNumber + buttonLimit + 1) {
            nextDot = true;
        }
        if (currentPageNumber > 2) {
            firstDot = true;
        }
        let startIndexToArray;
        if (currentPageNumber === 1) {
            startIndexToArray = currentPageNumber;
        } else {
            startIndexToArray = currentPageNumber - 1;
        }
        let endIndexToArray;
        if (currentPageNumber + buttonLimit >= this.pageNumberList.length) {
            endIndexToArray = this.pageNumberList.length - 1;
        } else {
            endIndexToArray = currentPageNumber + buttonLimit;
        }
        const DynamicPageArray = this.pageNumberList.slice(startIndexToArray, endIndexToArray);
        this.showFirstDot = firstDot;
        this.showNextDot = nextDot;
        this.pageListToShow = DynamicPageArray;
        this.pageListFirst = this.pageNumberList.slice(0, 1);
        if (this.pageNumberList.length !== 1) {
            this.pageListLast = this.pageNumberList.slice(this.pageNumberList.length - 1, this.pageNumberList.length + 1);
        } else {
            this.pageListLast = [];
        }
    }

    onNext = () => {
        if (this.currentPage < this.totalPagesToDisplay) {
            this.currentPage = Number(this.currentPage) + 1;
            this.paginatedData = this.fetchCurrentPageData();
            this.displayPageNumbers();
        }
    };

    onPrev = () => {
        if (this.currentPage > 1) {
            this.currentPage = Number(this.currentPage) - 1;
            this.paginatedData = this.fetchCurrentPageData();
            this.displayPageNumbers();
        }
    };

    displayPageDetails(event) {
        this.currentPage = event.target.dataset.id;
        this.paginatedData = this.fetchCurrentPageData();
        this.displayPageNumbers();
        this.addUnderline();
    }

    fetchCurrentPageData() {
        const startIndexCurrent = (this.currentPage * this.noOfRecordsPerPage) - this.noOfRecordsPerPage;
        const endIndexCurrent = (this.currentPage * this.noOfRecordsPerPage);
        return this.genericdata.slice(startIndexCurrent, endIndexCurrent);
    }

    addUnderline() {
        this.template.querySelectorAll('a.paginationlink').forEach((pagebutton) => {
            if (Number(this.currentPage) === parseInt(pagebutton.dataset.id, 10)) {
                pagebutton.style.borderBottom = '1.5px solid black';
                pagebutton.style.top = '5px';
            } else {
                pagebutton.style.textDecorationColor = 'none';
                pagebutton.style.borderBottom = 'none';
            }
            pagebutton.style.color = 'black';
        });
    }

    genericSortColumns(event) {
        const { fieldName } = event.detail;
        const { sortDirection } = event.detail;
        this.genericsortedby = fieldName;
        this.genericsorteddirection = sortDirection;
        if (this.sortWithinPaginatedData) {
            const currentPageData = this.fetchCurrentPageData();
            this.paginatedData = this.sortDataWithPaginatedData(fieldName, sortDirection, currentPageData);
        } else {
            const allPagesData = this.genericdata;
            this.genericdata = this.sortDataWithPaginatedData(fieldName, sortDirection, allPagesData);
            this.paginatedData = this.fetchCurrentPageData();
        }
    }

    @api
    sortDataWithPaginatedData(fieldName, direction, data) {
        const parseData = JSON.parse(JSON.stringify(data));
        if (fieldName === 'memberURL') {
            fieldName = 'memberName';
        }
        const keyValue = a => a[fieldName];
        const isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            let valX = keyValue(x) ? keyValue(x) : '';
            let valY = keyValue(y) ? keyValue(y) : '';
            valX = valX.toLowerCase();
            valY = valY.toLowerCase();
            return isReverse * ((valX > valY) - (valY > valX));
        });
        return parseData;
    }

    handleRowAction(event) {
        this.dispatchEvent(new CustomEvent('rowaction', { detail: event.detail }));
    }
}
