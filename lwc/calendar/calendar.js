import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FULLCALENDARJS from '@salesforce/resourceUrl/CellSight360Resource';

import CALENDAR_HELP_TEXT from '@salesforce/label/c.CalendarHelpText';
import MRN from '@salesforce/label/c.MRN';
import PATIENT_NAME from '@salesforce/label/c.PatientName';
import PATIENTID from '@salesforce/label/c.PatientId';


const APH_SELECT = 'apheresisSelectedDate';

export default class Calendar extends LightningElement {

  ApheresisIcon = `${FULLCALENDARJS}/images/24x24_apheresis.svg`;

  DeliveryIcon = `${FULLCALENDARJS}/images/24x24_delivery.svg`;

  error;

  fullCalendarJsInitialised = false;

  labels = {
    CALENDAR_HELP_TEXT,
    MRN,
    PATIENT_NAME,
    PATIENTID,
  }

  @track calendarObj;

  @track _events=[];

  @api set events(data) {
    if (data || Array.isArray(data)) {
      this._events = data;
      this.updateEvents();
    }
  }

  @api showWeekends = false;

  @api page='availablityCalendar';

  @api validRange = [];

  get events() {
    return this._events;
  }

  renderedCallback() {
    // Performs this operation only on first render
    if (this.fullCalendarJsInitialised) {
      return;
    }
    this.fullCalendarJsInitialised = true;
    Promise.all([
      loadStyle(this, `${FULLCALENDARJS}/css/fullcalendar/core.css`),
      loadScript(this, `${FULLCALENDARJS}/scripts/fullcalendar/fullcalendar.js`),
      loadScript(this, `${FULLCALENDARJS}/scripts/fullcalendar/popper.min.js`),
    ]).then(() => {
      Promise.all([
        loadStyle(this, `${FULLCALENDARJS}/css/fullcalendar/daygrid.css`),
        loadStyle(this, `${FULLCALENDARJS}/css/fullcalendar/timegrid.css`),
        loadScript(this, `${FULLCALENDARJS}/scripts/fullcalendar/fullcalendarInteracation.js`),
        loadScript(this, `${FULLCALENDARJS}/scripts/fullcalendar/daygrid.js`),
        loadScript(this, `${FULLCALENDARJS}/scripts/fullcalendar/timeline.js`),
        loadStyle(this, `${FULLCALENDARJS}/css/fullcalendar/tooltip.css`),
        loadScript(this, `${FULLCALENDARJS}/scripts/fullcalendar/tooltip.min.js`),
      ]).then(() => {
        this.initializeCalendar();
      }).catch((err) => {
        this.error = err;
      });
    }).catch((error) => {
      this.error = error;
    });
  }

  get isFullCalendarLoaded() {
    if (this.calendarObj && this.fullCalendarJsInitialised) {
      return true;
    }
    return false;
  }

  get isAvailCal() {
    if (this.page === 'availablityCalendar') {
      return true;
    }
    return false;
  }

  initializeCalendar() {
    const containerElement = this.template.querySelector('.fullcalendar');
    this.calendarObj = new FullCalendar.Calendar(containerElement, {
      plugins: ['interaction', 'dayGrid', 'timeGrid'],
      defaultView: 'dayGridMonth',
      weekends: this.showWeekends, // hide weekends
      header: false,
      datesRender: ({ view }) => {
        let str;
        switch (view.type) {
          case 'timeGridDay': str = new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            weekday: 'long',
          }).format(view.activeStart);
            break;
          case 'timeGridWeek':
            str = new Intl.DateTimeFormat('en-US', {
              year: 'numeric',
              month: 'long',
            }).format(view.activeStart);
            break;
          case 'dayGrid2Week':
            str = new Intl.DateTimeFormat('en-US', {
              month: 'long',
              day: 'numeric',
            }).format(view.activeStart);
            str = `${str} - ${new Intl.DateTimeFormat('en-US', {
              month: 'long',
              day: 'numeric',
              year: 'numeric',
            }).format(view.activeEnd.setDate(view.activeEnd.getDate() - 1))}`;
            break;
          case 'dayGridMonth':
            str = new Intl.DateTimeFormat('en-US', {
              year: 'numeric',
              month: 'long',
            }).format(view.activeStart);
            break;
          default:
            str = new Intl.DateTimeFormat('en-US', {
              year: 'numeric',
              month: 'long',
            }).format(view.activeStart);
        }
        this.template.querySelector('.title').innerHTML = str;
      },
      viewSkeletonRender: ({ view }) => {
        let str;
        switch (view.type) {
          case 'timeGridDay': str = new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            weekday: 'long',
          }).format(view.activeStart);
            break;
          case 'dayGrid2Week':
            str = new Intl.DateTimeFormat('en-US', {
              month: 'long',
              day: 'numeric',
            }).format(view.activeStart);
            str = `${str} - ${new Intl.DateTimeFormat('en-US', {
              month: 'long',
              day: 'numeric',
              year: 'numeric',
            }).format(view.activeEnd.setDate(view.activeEnd.getDate() - 1))}`;
            break;
          default:
            str = new Intl.DateTimeFormat('en-US', {
              year: 'numeric',
              month: 'long',
            }).format(view.activeStart);
        }
        this.template.querySelector('.title').innerHTML = str;
      },
      views: {
        dayGrid2Week: {
          type: 'dayGridWeek',
          fixedWeekCount: 2,
          duration: { weeks: 2 },
          dayCount: 10,
        },
        dayGridMonth: {
          eventLimit: 1,
        },
        week: {
          type: 'basic',
          duration: { weeks: 2 },
        },
        timeGrid: {
          eventLimit: 1,
        },
      },
      showNonCurrentDates: false,
      slotEventOverlap: true,
      eventLimit: true,
      events: [],
      dayMaxEvents: 2,
      eventLimitClick: (cellInfo) => {
        this.calendarObj.changeView('dayGrid2Week', cellInfo.date);
        const evt = new CustomEvent('viewchange', {
          detail: {
            view: 'dayGrid2Week',
          },
        });
        this.dispatchEvent(evt);
      },
      dateClick: (info) => {
        const evt = new CustomEvent('cellclick', {
          detail: {
            selecteddate: info.date,
          }
        });
        this.dispatchEvent(evt);
      },
      eventClick: (info) => {
        const elements = document.querySelectorAll('.tooltip[role="tooltip"]');
        if (elements) {
          elements.forEach(element => element.classList.add('slds-hide'));
        }
        if (info.event.extendedProps
            && (info.event.extendedProps.type === 'aphSelect'
                || info.event.extendedProps.type === 'aphDelivery'
                || info.event.extendedProps.type === 'delivery'
            )) {
          const evt = new CustomEvent('eventclick', {
            detail: {
              id: info.event.id,
              type: info.event.extendedProps.type,
              memberId: info.event.extendedProps.memberId,
              selecteddate: info.event.extendedProps.selecteddate,
            },
          });
          this.dispatchEvent(evt);
        }
      },
      dayRender: (info) => {
        if (this.page === 'patientMilestone') {
          const disableDay = [0, 1, 6];
          if (disableDay.indexOf(info.date.getDay()) > -1) {
            info.el.classList.add('fc-disabled-day');
          }
        } else if (this.page === 'infusionCalendar') {
          const disableDay = [];
        } else {
          const disableDay = [0, 6];
          if (disableDay.indexOf(info.date.getDay()) > -1) {
            info.el.classList.add('fc-disabled-day');
          }
        }
      },
      eventRender: (info) => {
        if (info.event.rendering != 'background'
        && info.event.id === APH_SELECT
        ) {
          const day = info.event.start.getDate();
          info.el.innerHTML = `<div>${day}</div>`;
        }
        if (info.event.rendering
            && info.event.rendering === 'background'
            && info.event.extendedProps.type !== 'delivery'
            && info.event.id !== APH_SELECT) {
          info.el.innerHTML =
              `<div class='hoverEffect' style='display:none;'>
                  <button class='available-select'>Select</button>
               </div>`;
          info.el.onmouseenter = function () {
            info.el.querySelector('.hoverEffect').style = 'display:flex';
          };
          info.el.onmouseleave = function (event) {
            info.el.querySelector('.hoverEffect').style = 'display:none';
          };
          const element = info.el.querySelector('.available-select');
          if (element) {
            element.addEventListener('click', () => {
              const evt = new CustomEvent('aphselect', {
                detail: {
                  date: info.event.start,
                  id: info.event.id,
                  selecteddate: info.event.extendedProps.selecteddate,
                  events: this._events,
                },
                bubbles: true,
                composed: true,
              });
              this.dispatchEvent(evt);
            });
          }
        }
        if (info.event.extendedProps && info.event.extendedProps.type === 'aphSelect') {
          info.el.innerHTML = `<div class="custom-event slds-p-around_xx-small">
                                <div class="slds-m-right_xx-small">
                                    <img src=${this.ApheresisIcon} alt="Apheresis" class="event-cal-icons"/>
                                </div>
                                <div class="text-ellipsis custom-event-text">${info.event.title}</div>
                                </div>`;
          try {
            const renderedTitle = `<div class="slds-grid slds-wrap slds-grid_vertical-align-center">
                                    <div class="slds-col slds-size_5-of-12">${this.labels.PATIENT_NAME}</div><div class="slds-col slds-size_7-of-12">: ${info.event.extendedProps.patientName}</div>
                                    <div class="slds-col slds-size_5-of-12">${this.labels.MRN}</div><div class="slds-col slds-size_7-of-12">: ${info.event.extendedProps.MRN}</div>
                                    <div class="slds-col slds-size_5-of-12">${this.labels.PATIENTID}</div><div class="slds-col slds-size_7-of-12">: ${info.event.extendedProps.patientId}</div>
                                 </div>`;
            const tooltip = new Tooltip(info.el, {
              title: `${renderedTitle}`,
              html: true,
              placement: 'top',
              trigger: 'hover',
              container: 'body',
            });
          } catch (e) {
            this.error = e;
          }
        }
        if (info.event.extendedProps && info.event.extendedProps.type === 'aphDelivery') {
          info.el.innerHTML = `<div class="custom-event slds-p-around_xx-small">
                                <div class="slds-m-right_xx-small">
                                    <img src=${this.DeliveryIcon} alt="Apheresis" class="event-cal-icons"/>
                                </div>
                                <div class="text-ellipsis custom-event-text">${info.event.title}</div>
                                </div>`;
          try {
            const renderedTitle = `<div class="slds-grid slds-wrap slds-grid_vertical-align-center">
                                    <div class="slds-col slds-size_5-of-12">${this.labels.PATIENT_NAME}</div><div class="slds-col slds-size_7-of-12">: ${info.event.extendedProps.patientName}</div>
                                    <div class="slds-col slds-size_5-of-12">${this.labels.MRN}</div><div class="slds-col slds-size_7-of-12">: ${info.event.extendedProps.MRN}</div>
                                    <div class="slds-col slds-size_5-of-12">${this.labels.PATIENTID}</div><div class="slds-col slds-size_7-of-12">: ${info.event.extendedProps.patientId}</div>
                                 </div>`;
            const tooltip = new Tooltip(info.el, {
              title: `${renderedTitle}`,
              html: true,
              placement: 'top',
              trigger: 'hover',
              container: 'body',
            });
          } catch (e) {
            this.error = e;
          }
        }
      },

    });

    if (this.page === 'patientMilestone' || this.page === 'infusionCalendar') {
      this.calendarObj.setOption('height', 380);
      this.calendarObj.setOption('aspectRatio', 1);
      if (this.validRange && this.validRange.length > 1) {
        const obj = {
          start: this.validRange[0],
          end: this.validRange[1],
        };
        this.calendarObj.setOption('validaRange', obj);
        this.calendarObj.gotoDate(this.validRange[0]);
      }
    }
    this.calendarObj.addEventSource(Array.from(this._events));
    this.calendarObj.render();
  }

  updateEvents() {
    if (this.calendarObj) {
      const eventSources = this.calendarObj.getEventSources();
      if (eventSources) {
        for (let i = 0; i < eventSources.length; i++) {
          eventSources[i].remove();
        }
      }
      this.calendarObj.addEventSource(this._events);
      this.calendarObj.refetchEvents();
    }
  }

  handlePrev() {
    if (this.fullCalendarJsInitialised && this.calendarObj) {
      this.calendarObj.prev();
      if (this.page === 'patientMilestone') {
        this.updateEvents();
      }
    }
  }

  handleNext() {
    if (this.fullCalendarJsInitialised && this.calendarObj) {
      this.calendarObj.next();
      if (this.page === 'patientMilestone') {
        this.updateEvents();
      }
    }
  }

  @api
  setViewAsWeek() {
    this.calendarObj.changeView('dayGrid2Week');
  }

  @api
  setViewAsMonth() {
    this.calendarObj.changeView('dayGridMonth');
  }
}
