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
td.NoBorder{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-InventoryMaintenance Print","request_item_print.jsp");
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
	String strTemp = null;
	int i = 0;
	int iCountRows = 0;
	double dTotalAmount = 0d;
	String strSchCode = dbOP.getSchoolIndex();	
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	int iIncr = 1;
			
	vReqInfo = InvMaint.operateOnTransferReqInfo(dbOP,request,3);
	vReqItems = InvMaint.operateOnTransferReqItems(dbOP,request,4);
	if(vReqItems != null)
	for(;i < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<form name="form_" method="post">
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr> 
      <td align="center" width="27%"><div align="right">&nbsp;
	  </div></td>
      <td width="46%" height="25" align="center"><div align="left">&nbsp;</div>
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br> 
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
		<strong><font size="+1"><br>
		TRANSFER REQUEST FORM</font></strong><br> 
		<br> </td>
      <td width="27%" align="center">&nbsp;</td>
     </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="17">&nbsp;</td>
      <td class="NoBorder"><strong>ITEM SOURCE</strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
		<%if(((String)vReqInfo.elementAt(1)).equals("0")){%> 
    <tr>
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Office </td>
      <td class="NoBorder"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
		<%}else{%>
    <tr>
      <td height="17">&nbsp;</td>
      <td class="NoBorder"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</td>
      <td class="NoBorder"><strong><%=(String)vReqInfo.elementAt(3)+"/"+WI.getStrValue((String)vReqInfo.elementAt(4),"All")%></strong></td>
      <td class="NoBorder">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
		<%}%>
    <tr>
      <td height="17">&nbsp;</td>
      <td colspan="4" class="NoBorder"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Requisition No.</td>
      <td class="NoBorder"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td class="NoBorder">Requested By</td>
      <td class="NoBorder"><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="17">&nbsp;</td>
      <td width="18%" class="NoBorder">Purpose/Job</td>
      <td width="31%" class="NoBorder"><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td width="15%" class="NoBorder">&nbsp;</td>
      <td width="34%" class="NoBorder">&nbsp;</td>
    </tr>
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Requisition Status</td>
      <td class="NoBorder"><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(13))]%></strong></td>
      <td class="NoBorder">Requisition Date</td>
      <td class="NoBorder"><strong><%=(String)vReqInfo.elementAt(12)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(5)).equals("0")){%> 
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder">Office</td>
      <td class="NoBorder"><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
      <td class="NoBorder">Date Needed</td>
      <td class="NoBorder"><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td class="NoBorder"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</td>
      <td class="NoBorder"><strong><%=(String)vReqInfo.elementAt(7)+"/"+WI.getStrValue((String)vReqInfo.elementAt(8),"All")%></strong></td>
      <td class="NoBorder">Date Needed</td>
      <td class="NoBorder"><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%} // end if  (((String)vReqInfo.elementAt(3)).equals("0"))%>
  </table>
  <%if(vReqItems != null){%>
  <br>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	  <tr>
	  <td height="17" colspan="4" class="thinborder"><div align="center"><strong>LIST 
         OF REQUESTED SUPPLIES</strong></div></td>
	  </tr>  	  
    <tr> 
      <td width="16%" height="17" class="thinborder"><div align="center"><strong>ITEM CODE </strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="67%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;i < vReqItems.size() && iCountRows < iNumRows;i+=11,++iCountRows,iIncr++){%>
    <tr> 
      <td  height="17" class="thinborder">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(i+10),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=vReqItems.elementAt(i+2)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=vReqItems.elementAt(i+3)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=vReqItems.elementAt(i+4)%></div></td>
      <%if(vReqItems.elementAt(i+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(i+7));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
	<tr> 
      <td height="17" colspan="4" class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td  height="17" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iIncr-1%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22">&nbsp;</td>
    </tr>
  </table>
	<%if (i < vReqItems.size()) {%>
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