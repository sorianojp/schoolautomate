<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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


TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
}
TABLE.thinborderALL {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderRight {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBottomRight {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderALL {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>
</head>
<body onLoad="window.print()" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	

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
	
	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strTemp = null;
	int iLoop = 2;
	int iCountRows = 0;
	double dTotalAmount = 0d;
	
	
	String strInfo5 = SchoolInformation.getInfo5(dbOP, false, false);	

	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	boolean bolShowPresident = false;
			
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);	
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{
		if(((String)vReqInfo.elementAt(3)).equals("0")){
		  if ((WI.getStrValue((String)vReqInfo.elementAt(9),"").toLowerCase()).equals("office of the president")){
			bolShowPresident = true;
		  }
		}
	}
	String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
	vReqItems = REQ.operateOnReqItems(dbOP,request,4);
	if(vReqItems != null)
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<form name="form_" method="post">
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td width="14%" align="right">
			<img src="../../../images/logo/UB_BOHOL.gif" border="0" width="70" height="70">		</td>
		
	    <td width="41%" align="center">
		<strong style="font-size:13px;"><%=strSchName%></strong><br>
		<strong style="font-size:15px;">REQUISITION FORM</strong>
		</td>
	    <td width="45%" align="right" style="padding-right:40px;" valign="top">
		<div style="border:solid 1px #000000; width:50%; height:40px; text-align:left;">Request No.<br><strong><%=WI.fillTextValue("req_no")%></strong></div>
		</td>
  	</tr>
  </table>
  <%
  if(vReqItems != null){%>  
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	 <tr>
		<td height="25" colspan="2" class="thinborder">Requesting Department : <%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></td>
		<td  class="thinborder" colspan="3">Date of Request : <%=(String)vReqInfo.elementAt(7)%></td>
		</tr>
  	<tr>
  	    <td class="thinborder" height="25" colspan="5">Purpose of Request: <%=(String)vReqInfo.elementAt(5)%></td>
  	    </tr>
  	<tr>
  	    <td class="thinborder" height="25" colspan="5">Charge to budgetary allocation</td>
  	    </tr> 
    <tr>
  	    <td height="25" colspan="2" align="center" class="thinborder">Items</td>
  	    <td class="thinborder" align="center">Quantity</td>
  	    <td class="thinborder" align="center">Price</td>
  	    <td class="thinborder" align="center">Amount</td>
  	</tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr>
		<td height="22" colspan="2" class="thinborder"><%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%></td>
		<td class="thinborder" width="13%" align="center"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;<%=vReqItems.elementAt(iLoop+2)%></td>
		<td class="thinborder" width="13%"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%>&nbsp;</div></td>
		<td class="thinborder" width="13%" align="right"><%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%></td>
	</tr>
    <%}	%>	
	<tr> 
      <td height="22" colspan="5" align="center" class="thinborder">********** NOTHING FOLLOWS **********</td>
      </tr>

    <tr>
        <td width="53%" height="22" valign="top" class="thinborder" style="font-size:12px;">
			1. Requested By<div style=" text-align:center; margin-top:30px; vertical-align:bottom;"><strong><%=WI.getStrValue((String)vReqInfo.elementAt(2)).toUpperCase()%></strong></div>
			<div style="text-align:center;">Person Authorized/Department Head</div></td>
        <td colspan="4" valign="top" class="thinborder" style="font-size:12px;">3. Approved
		<div style="text-align:center; vertical-align:bottom; margin-top:30px;"><strong>DR. VICTORIANO R. TIROL</strong></div>
		<div style="text-align:center;">VP-Admin</div></td>
        </tr>
    <tr>
		<%
		strTemp = "Ms. Elvie S. Kudemos";
		%>
        <td height="22" class="thinborder" style="font-size:12px;">2. OK as to budget
		<div style=" text-align:center; margin-top:30px; vertical-align:bottom;"><strong><%=strTemp.toUpperCase()%></strong></div>
		<div style="text-align:center;">Budget Officer</div></td>
		<%
		strTemp = "DR. Cristeta B. Tirol";
		%>
        <td height="22" colspan="4" class="thinborder" style="font-size:12px;">		
			4. Approved<div style=" text-align:center; margin-top:30px; vertical-align:bottom;"><strong><%=strTemp.toUpperCase()%></strong></div>
			<div style="text-align:center;">Vice President for Finance</div></td>
        </tr>
    <%}%>
  </table>  
  
  
  
  
  
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	
    } // if(vReqItems != null)%
	%>
  <%} // if(vReqInfo != null)  	
	//}// outermost for loop%>
	<input type="hidden" name="num_rows" value="<%=WI.fillTextValue("num_rows")%>">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>