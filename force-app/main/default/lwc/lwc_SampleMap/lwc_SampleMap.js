import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Account.Name'
    , 'Account.BillingPostalCode'
    , 'Account.BillingCountry'
    , 'Account.BillingState'
    , 'Account.BillingCity'
    , 'Account.BillingStreet'
    , 'Account.BillingLatitude'
    , 'Account.BillingLongitude'
];

export default class Lwc_SampleMap extends LightningElement {
    @track mapMarkers = [];

    @api recordId;

    @api zoomLevel;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    wiredAccount({ data }) {
        if(data){
            let markers = [];
            let description = data.fields.BillingPostalCode.value + '<br/>'
            description += data.fields.BillingCountry.value + ' '
            description += data.fields.BillingState.value + '<br/>'
            description += data.fields.BillingCity.value + '<br/>'
            description += data.fields.BillingStreet.value + '<br/>'
            
            
            markers.push({
                location: {
                    Latitude: data.fields.BillingLatitude.value,
                    Longitude: data.fields.BillingLongitude.value,
                },
                title: data.fields.Name.value,
                description: description, 
                icon: 'standard:account',
            });
            this.mapMarkers = markers;
        }
    }

    onClickOpenGoogleMap(){
        let url = 'https://maps.google.com/maps?q=';
        url += this.mapMarkers[0].location.Latitude + ',';
        url += this.mapMarkers[0].location.Longitude;
        url += '&z=' + this.zoomLevel;

        window.open(url);
    }
}