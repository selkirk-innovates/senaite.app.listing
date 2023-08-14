from bika.lims import api
from senaite.app.listing.interfaces import IListingView
from senaite.app.listing.interfaces import IListingViewAdapter
from senaite.app.listing.utils import add_column
from senaite.app.listing.utils import add_review_state
from zope.component import adapts
from zope.interface import implements

from Products.Archetypes.public import DisplayList
from bika.lims import bikaMessageFactory as _

# imported by /buildout-cache/eggs/cp27mu/senaite.core-2.4.1-py2.7.egg/bika/lims/content/analysisrequest.py
TURNAROUNDTIME = DisplayList((
   ('1', _('1 hr')),
   ('2', _('3 hrs')),
   ('3', _('6 hrs')),
   ('4', _('24 hrs')),
   ('5', _('48 hrs')),
   ('6', _('72 hrs')),
   ('7', _('96 hrs')),
   ('8', _('1 week')),
))

# The following code is used to display the text, rather than the id (ex: '3 hrs' instead of '2') by creating a dictionary and then applying it in the final step.
TURNAROUND = [
   ('1', ('1 hr')),
   ('2', ('3 hrs')),
   ('3', ('6 hrs')),
   ('4', ('24 hrs')),
   ('5', ('48 hrs')),
   ('6', ('72 hrs')),
   ('7', ('96 hrs')),
   ('8', ('1 week')),
]

turnAroundDictionary = { v[0]: v[1] for v in TURNAROUND }

class SamplesListingViewAdapter(object):
    adapts(IListingView)
    implements(IListingViewAdapter)

    def __init__(self, listing, context):
        self.listing = listing
        self.context = context

    def before_render(self):
        # Add a new filter status
        draft_status = {
            "id": "draft",
            "title": "Draft",
            "contentFilter": {
                "review_state": "sample_draft",
                "sort_on": "created",
                "sort_order": "descending",
            },
            "columns": self.listing.columns.keys(),
        }
        self.listing.review_states.append(draft_status)

        # Add the column
        self.listing.columns["TurnAroundTime"] = {
            "title": "Turn-Around Time",
            "sortable": True,
            "toggle": True,
        }

        # Make the new column visible for all filter statuses
        for filter in self.listing.review_states:
            filter.update({"columns": self.listing.columns.keys()})
    
    def folder_item(self, obj, item, index):
        sample = api.get_object(obj)
        item["TurnAroundTime"] = turnAroundDictionary[sample.getField("TurnAroundTime").get(sample)] or "Empty value"
        return item
    
