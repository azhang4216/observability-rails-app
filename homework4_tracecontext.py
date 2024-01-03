'''
Angela Zhang
November 28, 2023, revised January 2, 2024
Observability (Prof. Emily Stolfo)
'''
import re
import secrets


# Constants
CURR_ID = "63674ce9eb26b347" # A 16-character hexadecimal value for outgoing header's parent_id
DATACAT_TRACESTATE = "dc=.2" # DataCat's identifier is dc and the sample rate is 20%.

# Helper function update_dc_substring takes in tracestate string, 
# Returns a string with 
def update_dc_substring(input_string):
    if not input_string or input_string == DATACAT_TRACESTATE:
        return DATACAT_TRACESTATE

    # Replace dc=... substring if it exists
    target_substring_pattern = re.compile(r'dc=(\d|(\.\d+)?),')
    match = target_substring_pattern.search(input_string)

    if match:
        # dc=... is not the last key/value pair
        updated_string = target_substring_pattern.sub('', input_string)
    else:
        # dc=... is the last key/value pair
        updated_string = re.sub(r',dc=(\d|(\.\d+)?)', '', input_string)

    # DataCat Tracestate should always be at the front
    updated_string = f"{DATACAT_TRACESTATE},{updated_string}"

    return updated_string

# Function insert_datacat_tracestate takes in dictionary object header,
# Returns a header object with inserted DataCat tracestate.
def insert_datacat_tracestate(header):
    traceparent = header.get("traceparent", "")
    tracestate = header.get("tracestate", "")

    # First, we create the outgoing traceparent
    updated_traceparent = ""
    if traceparent:
        version, trace_id, _parent_id, flags = traceparent.split("-")
        updated_traceparent = f"{version}-{trace_id}-{CURR_ID}-{flags}"
    else:
        '''
        According to the W3C Trace Context specification, 
        if an incoming request does not have a traceparent header, 
        the server should generate a new trace identifier for the outgoing response. 
        The traceparent header should be added to the outgoing response, 
        and its value should be a new trace identifier formatted [version]-[trace-id]-[parent-id]-[flags].
        '''
        version = "00" # The version of the W3C Trace Context specification. The current version is "00".
        flags = "01" # The least significant bit (LSB) is the sampled flag, indicating whether the trace is sampled.

        random_bytes = secrets.token_bytes(16)
        trace_id = random_bytes.hex() # A 32-character hexadecimal value
        
        updated_traceparent = f"{version}-{trace_id}-{CURR_ID}-{flags}"

    # Second, we create the outgoing tracestate
    updated_tracestate = update_dc_substring(tracestate) if tracestate else DATACAT_TRACESTATE

    outgoing_header = {
        "traceparent": updated_traceparent,
        "tracestate": updated_tracestate
    }

    return outgoing_header

# The given example:
incoming_header = {
    "traceparent": "00-0af7651916cd43dd8448eb211c80319c-b9c7c989f97918e1-01",
    "tracestate": "congo=ucfJifl5GOE,rojo=00f067aa0ba902b7"
}
expected_header = { 
    "traceparent": "00-0af7651916cd43dd8448eb211c80319c-63674ce9eb26b347-01",
    "tracestate": "dc=.2,congo=ucfJifl5GOE,rojo=00f067aa0ba902b7" 
}

outgoing_header = insert_datacat_tracestate(incoming_header)
# print(expected_header == outgoing_header) # Should be True
# print(outgoing_header)

# Assignment questions:
input_headers = [
    { 
        "traceparent": "00-0af7651916cd43dd8448eb211c80319c-b9c7c989f97918e1-01",
        "tracestate": "congo=ucfJifl5GOE,rojo=00f067aa0ba902b7" 
    }, 
    { 
        "traceparent": "00-0af7651916cd43dd8448eb211c80319c-b9c7c989f97918e1-01",
        "tracestate": "dc=.2,congo=ucfJifl5GOE" 
    },
    { 
        "traceparent": "00-0af7651916cd43dd8448eb211c80319c-b9c7c989f97918e1-01",
        "tracestate": "congo=ucfJifl5GOE,dc=1" 
    },
    { 
        "tracestate": "congo=ucfJifl5GOE,dc=1" 
    },
    { 
        "traceparent": "00-0af7651916cd43dd8448eb211c80319c-b9c7c989f97918e1-01" 
    },
    { }
]

for i in range(len(input_headers)):
    outgoing_header = insert_datacat_tracestate(input_headers[i])
    print(outgoing_header)