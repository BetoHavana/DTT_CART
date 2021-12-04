import { LightningElement, track,wire,api} from 'lwc';
import getTopicList from '@salesforce/apex/KnowledgeArticleController.getTopicList';
import getArticles from '@salesforce/apex/KnowledgeArticleController.getArticles';
import ERROR_TOPICS from '@salesforce/label/c.ErrorTopics';
import ERROR_ARTICLES from '@salesforce/label/c.ErrorArticles';
import RESOURCES_LABEL from '@salesforce/label/c.Resources';
import SELECT_TOPIC from '@salesforce/label/c.SelectTopic';
import { NavigationMixin } from 'lightning/navigation';

export default class KnowledgeDataArticles extends NavigationMixin(LightningElement) {
    @track topics =[];

    @track topicId;

    @track articles;

    @track noArticles;

    @track error;

    @api pageType;
    labels = {
        ERROR_TOPICS,
        ERROR_ARTICLES,
        RESOURCES_LABEL,
        SELECT_TOPIC
    };

    @wire(getTopicList,{pageType: '$pageType'})
    wiredTopics({ error, data }) {
        if (data) {
            this.topics = JSON.parse(data);
            this.error = null;
        } else {
            this.error = error;
        }
    }

    doGetArticles(event) {
        this.topicId = event.target.name;
        getArticles({topicId : this.topicId})
        .then(result => {
            this.articles = result;
            this.noArticles = false;
            if(this.articles.length === 0){
                this.noArticles = true;
            }
            this.error = null;
        }).catch(error => {
            this.error = error;
        })
    }

    navigateArticleDetail(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                urlName: event.target.name
            }
        });
    }

    get pageHeader() {
        if (this.pageType) {
            return this.pageType;
        }
        return '';
    }

}
