<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderALL {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Print","req_item_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
 	InventoryMaintenance InvMaint = new InventoryMaintenance();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strTemp = null;
	int iLoop = 0;
	int iCountRows = 0;
	double dTotalAmount = 0d;
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	double dRequested = 0d;
	double dIssued = 0d;
	double dNotAvailable = 0d;
	double dAvailable = 0d;
			
	vReqInfo = InvMaint.operateOnTransferReqInfo(dbOP,request,3);	
	if(vReqInfo == null)
		strErrMsg = InvMaint.getErrMsg();

	
	vReqItems = InvMaint.getRequestedItems(dbOP, request, true);		
	if(vReqItems != null)
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<form name="form_" method="post">
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="9%" rowspan="2" align="center" valign="top">&nbsp;</td>
        <td width="66%" rowspan="2" valign="top">&nbsp;</td>
        <td height="25" colspan="3" valign="top">&nbsp;</td>
      </tr>      
      <tr>
        <td width="7%" valign="top">&nbsp;</td>
        <td width="7%" height="22">R.F. No. </td>
        <td width="11%" valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;<%=WI.fillTextValue("req_no")%></font></strong></td>
      </tr>
      <tr>
        <td colspan="3" align="center" valign="top">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="18%" class="NoBorder">College/Unit</td>
					<%
 					if(((String)vReqInfo.elementAt(5)).equals("0"))
							strTemp = (String)vReqInfo.elementAt(8);
						else
							strTemp = (String)vReqInfo.elementAt(7)+ "/" +WI.getStrValue((String)vReqInfo.elementAt(8),"All");
					%>
            <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
            <td width="36%">&nbsp;</td>
          </tr>
        </table></td>

        <td height="25">&nbsp;</td>
        <td valign="bottom">&nbsp;</td>
      </tr>
  </table>
  <%if(vReqItems != null){%>
  <br>

  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr>
      <td  height="17" colspan="5" align="center" class="thinborder"><strong>LIST OF REQUESTED ITEMS</strong></td>
	</tr> 
    <tr> 
      <td width="9%" height="17" align="center" class="thinborder">&nbsp;</td>
      <td width="41%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></td>
      <td width="13%" align="center" class="thinborder"><strong>AVAILABLE</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>NOT AVAILABLE</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>REMARKS</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=8,++iCountRows){%>
    <tr> 
			<%
				strTemp = (String)vReqItems.elementAt(iLoop+1);
				dRequested = Double.parseDouble(WI.getStrValue(strTemp,"0"));
			%>
      <td  height="17" align="right" class="thinborder"><%=strTemp%>&nbsp;<%=vReqItems.elementAt(iLoop+2)%>&nbsp;</td>
      <td class="thinborder"><%=vReqItems.elementAt(iLoop+3)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+4),"-","","")%></td>
			<%
				strTemp = (String)vReqItems.elementAt(iLoop+7);
				strTemp = CommonUtil.formatFloat(strTemp, false);
 			%>			
      <td align="right" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,""," " +(String)vReqItems.elementAt(iLoop+2),"&nbsp;")%>&nbsp;</td>
			<%
				dNotAvailable = dRequested - dAvailable;
				strTemp = Double.toString(dNotAvailable);
				if(dNotAvailable <= 0)
					strTemp = "";
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,""," " +(String)vReqItems.elementAt(iLoop+2),"&nbsp;")%>&nbsp;</td>
			<%
				strTemp = (String)vReqItems.elementAt(iLoop+5);
				if(Double.parseDouble(strTemp) <= 0)
					strTemp = "";
			%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"Issued "," " + (String)vReqItems.elementAt(iLoop+2),"")%></td>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
  </table>  	
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="50%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td colspan="5">To be filled up by requester </td>
          </tr>
        <tr>
          <td width="15%">Purpose:</td>
          <td colspan="4"><strong><font size="1"><%=(String)vReqInfo.elementAt(10)%></font></strong></td>
          </tr>
        <tr>
          <td colspan="5">&nbsp;</td>
          </tr>
        <tr>
          <td colspan="2">Date Needed :</td>
          <td colspan="3"><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></font></strong></td>
          </tr>
        <tr>
          <td colspan="2">Prepared by: </td>
          <td colspan="3">&nbsp;</td>
          </tr>
        <tr>
          <td colspan="3" class="thinborderBottom">&nbsp;</td>
          <td width="4%">&nbsp;</td>
					<%
						strTemp = WI.fillTextValue("date_updated");
					%>
          <td width="49%" align="center" class="thinborderBottom"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
        </tr>
        <tr>
          <td colspan="3" align="center">Dean/Head </td>
          <td>&nbsp;</td>
          <td align="center"> Date </td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td width="14%">&nbsp;</td>
          <td width="18%">&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
      <td width="50%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td colspan="3" align="right"><p>To be filled up by Purchasing and Supply Office </p>            </td>
        </tr>
        <tr>
          <td width="62%" align="right">&nbsp;</td>
          <td width="38%" colspan="2">/ &nbsp;/ Recommended </td>
          </tr>
        <tr>
          <td align="right">&nbsp;</td>
          <td colspan="2">/&nbsp; / Disapproved </td>
          </tr>
        

      </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td colspan="3" class="thinborderBottom">&nbsp;</td>
            <td>&nbsp;</td>
            <td class="thinborderBottom">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="3" align="center">Vice President Concerned </td>
            <td width="6%">&nbsp;</td>
            <td width="28%" align="center">Date</td>
          </tr>
        </table>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="20%">&nbsp;</td>
            <td width="28%">Remark</td>
            <td width="24%">&nbsp;</td>
            <td width="28%">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>/ &nbsp;/ Urgent </td>
            <td>/ &nbsp;/ Justified </td>
            <td>/&nbsp; / Others </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22">&nbsp;</td>
    </tr>
  </table>
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	
    } // if(vReqItems != null)%
	%>
  <%} // if(vReqInfo != null)  	
	}// outermost for loop%>
	<input type="hidden" name="num_rows" value="<%=WI.fillTextValue("num_rows")%>">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>