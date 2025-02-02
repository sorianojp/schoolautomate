<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>

 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }
  
  div.requisition_no{
    display:block;   
	width:13%;
    position:absolute;
    left:100;
	top:50;  
	background:#FFFFFF;   
  }
  
  
 </style>
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>

</script>
<body>
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-DELIVERY","memo_receipt.jsp");
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
	
Delivery DEL = new Delivery();	
Vector vReqInfo = null;

Vector vReqItems = null;
Vector vRetResult = null;

String strReceivingNo = null;
int iCount = 1;
String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
String[] astrReqType = {"New","Replacement"};
String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	

	vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		
	
		if(Integer.parseInt(WI.getStrValue((String)vReqInfo.elementAt(3),"0")) != 1){
			strErrMsg = "PO not yet approved";
		}else{
			
			strTemp = "select receiving_no from PUR_DELIVERY where IS_VALID =1 and PO_INDEX = "+(String)vReqInfo.elementAt(0);
			strReceivingNo = dbOP.getResultOfAQuery(strTemp, 0);
			
			vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0), true);
			if(vRetResult == null)
				strErrMsg = DEL.getErrMsg();
			else
				vReqItems = (Vector)vRetResult.elementAt(1);
		}
	}

if(vReqInfo != null && vReqInfo.size() > 1){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="2" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	  <em>(formerly Visayan Maritime Academy)</em><br>
<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br><br>
	PROPERTY CUSTODIAN<br><br>MEMORANDUM RECEIPT FOR EQUIPMENT<br>
	SEMI-EXPENDABLE AND NON-EXPENDABLE PROPERTY</td>
    </tr>
    <tr>
        <td height="25" align="center">&nbsp;</td>
        <td height="25" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td width="50%" height="22" align="center">&nbsp;</td>
      <td width="50%" align="center">Date : <u><%=WI.getTodaysDate(6)%></u></td>
    </tr>
    <tr>
        <td align="center">&nbsp;</td>
        <td valign="bottom" height="22" align="center">&nbsp;</td>
    </tr>
    <tr>
        <td>The Property Custodian</td>
        <td height="22" align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="22">&nbsp;</td>
        <td align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="22">Sir/ Madam: ______________________</td>
        <td align="center">&nbsp;</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td valign="bottom" height="25" align="center">&nbsp;</td>
    </tr>
	<tr>
        <td height="25" colspan="2" style="text-indent:40px; text-align:justify">
			I acknowledge to have received the following property of which 
			I am responsible and peculiarly liable, in case of damage due to improper 
			use/ loss due to my proven negligence.
		</td>
    </tr>
</table>


  

<%if(vReqItems != null && vReqItems.size() > 3){%>	
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">   
	
	<tr>
		<td width="8%" height="22" align="center" class="thinborder"><strong>QTY</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
		<td width="56%" align="center" class="thinborder"><strong>DESCRIPTION</strong></td>
		<td width="13%" align="center" class="thinborder"><strong>Unit Price</strong></td>
		<td width="13%" align="center" class="thinborder"><strong>TOTAL</strong></td>
	</tr>
	
   
    <%iCount = 1;
	double dTotal = 0d;
	for(int i = 0;i < vReqItems.size();i+=16,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(i+12)%></div></td>
      <td align="center" class="thinborder"><%=(String)vReqItems.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(i+3)%> / <%=(String)vReqItems.elementAt(i+4)%><%=WI.getStrValue((String)vReqItems.elementAt(i+9),"(",")","")%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vReqItems.elementAt(i+14),true)%></td>
	  <%
	  strTemp = (String)vReqItems.elementAt(i+15);
	  try{
	  	dTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));
	  }catch(Exception e){
	  	dTotal += 0d;
	  }
	  %>
      <td class="thinborder" align="right"><%=strTemp%></td>     
    </tr>
    
    <%}%>
	
	<tr>
        <td height="25" class="thinborder">&nbsp;</td>
        <td align="center" class="thinborder">&nbsp;</td>
        <td class="thinborder">&nbsp;</td>
        <td class="thinborder" align="right"><strong>TOTAL</strong></td>
        <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotal,true)%></td>
    </tr>
</table>	
  
<table cellpadding="0" cellspacing="0" border="0" Width="100%">
	<tr>
	    <td valign="top">&nbsp;</td>
	    <td colspan="2" style="text-align:justify">&nbsp;</td>
    </tr>
	<tr>
		<td width="12%" valign="top">IMPORTANT:</td>
		<td colspan="2" style="text-align:justify">
			To be accounted for and surrendered to the school Property Custodian; in case of assignment, 
			transfer, termination, resignation or retirement, 
			this will be a reference for clearance purposes.		</td>
	</tr>
	<tr>
	    <td height="60" valign="top">&nbsp;</td>
	    <td width="50%">&nbsp;</td>
        <td width="38%" align="center" valign="bottom"><u><%=(String)vReqInfo.elementAt(5)%></u><br>Name</td>
	</tr>
	<tr>
	    <td height="60" valign="top">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td align="center" valign="bottom"><u><%=(String)vReqInfo.elementAt(11)%></u><br>Office</td>
    </tr>
</table>
  

<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID.</td>
		<td>: Property 0023</td>
	</tr>
	<tr>
		<td>Rev. Number</td>
		<td>: 01</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 09.01.06</td>
	</tr>
</table>
</div>

<div id="requisition_no" class="requisition_no">
<table cellpadding="0" cellspacing="0" border="0" Width="100%">	
	<tr>
		<td width="100%"><div style="border-bottom: solid 1px #000000;"><%=WI.getStrValue(strReceivingNo, "&nbsp;")%></div></td>		
	</tr>
</table>
</div>

 <script>window.print();</script>
	<%}// end if(vReqItems != null && vReqItems.size() > 3)
}%>


</body>
</html>
<%
dbOP.cleanUP();
%>