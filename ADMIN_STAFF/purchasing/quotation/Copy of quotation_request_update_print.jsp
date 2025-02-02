<%@ page language="java" import="utility.*,purchasing.Quotation,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Quotation request</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<body>
<%	
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	double dTotalAmount = 0d;
	double dGrandTotal = 0d;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-UPDATE QUOTATION STATUS"),"0"));
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
								"Admin/staff-PURCHASING-UPDATE QUOTATION STATUS-Update QUOTATION Status","quotation_request_update_print.jsp");
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
	Quotation QTN = new Quotation();
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vSuppliers = null;
	Vector vAddtlCost = null;
	Vector vReqItemsQtn = null;
	boolean bolIsApproved = false;
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex = WI.fillTextValue("req_index");
	String strSchCode = dbOP.getSchoolIndex();
	String strTemp1 = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strStatus = null;
	int iLoop = 0;
	int iCount = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		if(WI.fillTextValue("req_no").length() == 0){
		strErrMsg = "Please enter Requisition Number";
		}else{
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null){
			strErrMsg = REQ.getErrMsg();
		}else{
			strReqIndex = (String)vReqInfo.elementAt(1);
			if(WI.fillTextValue("saveClicked").equals("1")){				
				if(QTN.approveReqBudget(dbOP,request))
					strErrMsg = "Status Saved.";
				else
					strErrMsg = QTN.getErrMsg();
			}
		}
		
		if (vReqInfo != null && vReqInfo.size() > 0){
			if ((String)vReqInfo.elementAt(0) == null){
				vSuppliers = QTN.showQTNSuppliers(dbOP,strReqIndex);
			}else{
				//System.out.println("Supplier 2");
				vSuppliers = QTN.showQTNSuppliers(dbOP,(String)vReqInfo.elementAt(0));
			}
		}
		
		if(vReqInfo != null && vReqInfo.size() > 1){
			if (vReqInfo.elementAt(0) != null){					
					//System.out.println("Supplier 2");					
				strReqIndex = (String)vReqInfo.elementAt(0);
			}
//			if(WI.fillTextValue("print_supplier").length() == 0){
			vReqItemsQtn = QTN.getRequestItems(dbOP,request,strReqIndex);
				//System.out.println("vReqItemsQtn " + vReqItemsQtn);
	//		}else{
		//		vReqItemsQtn = QTN.getRequestItems(dbOP,request,strReqIndex);
				//vReqItems = 
			//}
		}
		vAddtlCost = QTN.operateOnReqItemsQtn(dbOP,request,4,strReqIndex);
		}
	}// end if WI.fillTextValue("proceedClicked").equals("1")){
	
%>	
<form name="form_" method="post" action="quotation_request_update_print.jsp">
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<%if(!strSchCode.startsWith("UI")){%>
	<tr> 
	 <td align="center" width="27%"><div align="right">&nbsp;
	  <%if(strSchCode.startsWith("CPU")){%>
	  <img src="../../../images/logo/CPU.gif" width="70" height="70" border="0">
	  <%}%>
	  </div></td>		
    <td height="25" colspan="2" width="46%"><div align="center"> <strong>
	        <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
          <font size="+2"><strong>CANVASS FORM</strong></font></div></td>
	 <td align="center" width="27%"><div align="right">&nbsp;</div></td>		  
  </tr>
  <%}else{%>
  	<tr> 
    <td height="25" colspan="4">&nbsp;<br><br><br><br><br></td>
  </tr>
  <%}// if the school code starts with UI %>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(WI.fillTextValue("is_canvass").length() < 1){%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("req_no")%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="17">&nbsp;</td>
      <td width="18%"><font size="1">Request Type</font></td>
      <td width="31%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></font></td>
      <td width="15%"><font size="1">Purpose/Job</font></td>
      <td width="34%"><strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
    </tr>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(7)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Non-Acad. Office/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">College/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%} // end if  (((String)vReqInfo.elementAt(3)).equals("0"))
	}else{%>
	<tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Canvassing No. </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_no")%></font></strong></td>
      <td><font size="1">Canvassing Date </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_date")%></font></strong></td>
    </tr>
	<%}// end if(WI.fillTextValue("is_canvass").length() < 1)%>
  </table>
  <%if(vReqItemsQtn != null && vReqItemsQtn.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST 
          OF REQUESTED ITEMS</strong></div></td>
    </tr>
    <tr> 
      <td width="5%" height="26" class="thinborder"><div align="center"><font size="1"><strong>QTY</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>ITEM 
          / PARTICULARS / DESCRIPTION </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SUPPLIER 
          CODE</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>PRICE 
          QUOTED</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNT</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>UNIT 
          PRICE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          AMOUNT</strong></font></div></td>
    </tr>
    <%//System.out.println("size " + vReqItemsQtn.size());
	for(iLoop = 0,iCount = 0;iLoop < vReqItemsQtn.size();iLoop+=11,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=vReqItemsQtn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsQtn.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsQtn.elementAt(iLoop+3)%> / <%=vReqItemsQtn.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+5),"")%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+10),"(",")","")%> 
          <%
			strTemp1 = "";
			strTemp2 = "";
			strTemp3 = "";
			strErrMsg = "";			
			for(; (iLoop + 11) < vReqItemsQtn.size() ;){
			//System.out.println("iLoop " +(String)vReqItemsQtn.elementAt(iLoop));
			//System.out.println("iLoop11 " +(String)vReqItemsQtn.elementAt(iLoop + 11));
			 if(!(((String)vReqItemsQtn.elementAt(iLoop)).equals((String)vReqItemsQtn.elementAt(iLoop + 11))))
					break;			 
			 strErrMsg += (String)vReqItemsQtn.elementAt(iLoop+6)+ "<br>";
			 strTemp1 += (String)vReqItemsQtn.elementAt(iLoop+7)+ "<br>";
			 strTemp2 += (String)vReqItemsQtn.elementAt(iLoop+9)+ "<br>";
			 strTemp3 += (String)vReqItemsQtn.elementAt(iLoop+8)+ "<br>";%>
          <br>
          <%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop + 11 + 5),"")%><%=WI.getStrValue((String)vReqItemsQtn.elementAt(iLoop+10),"(",")","")%> 
          <%iLoop += 11;}%>
        </div></td>
      <td class="thinborder"><div align="right"><%=strErrMsg + (String)vReqItemsQtn.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="right"> <%=strTemp1 + (String)vReqItemsQtn.elementAt(iLoop+7)%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp2 + (String)vReqItemsQtn.elementAt(iLoop+9)%></div></td>
      <td class="thinborder"><div align="right"><%=strTemp3 + (String)vReqItemsQtn.elementAt(iLoop+8)%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount%> 
          <input type="hidden" name="num_of_items" value="<%=iCount%>">
          </strong></div></td>
    </tr>
  </table>
  <%}// end for vReqItemsQtn != null %>
  <%if(vAddtlCost != null && vAddtlCost.size() > 2){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><strong>ADDITIONAL 
          COST FOR THIS REQUISITION</strong></div></td>
    </tr>
    <tr> 
      <td width="35%" class="thinborder"><div align="center"><strong>SUPPLIER 
          NAME</strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>COST NAME 
          </strong></div></td>
      <td width="28%" height="25" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%
	for(iLoop = 2;iLoop < vAddtlCost.size();iLoop+=5){%>
    <tr> 
      <td  height="25" class="thinborder"><%=vAddtlCost.elementAt(iLoop+2)%> <%/*strTemp1 = "";
	  	strTemp2 = "";
	  for(;(iLoop+3+5) < vRetResult.size();){
	  		if(!((String)vRetResult.elementAt(iLoop+1)).equals((String)vRetResult.elementAt(iLoop+1+5)))
	  			break;
			strTemp1 += (String)vRetResult.elementAt(iLoop+3)+"<br>";
			strTemp2 += (String)vRetResult.elementAt(iLoop+4)+"<br>";
			iLoop+=5;
	    }*/%> </td>
      <td class="thinborder"><%=/*strTemp1+*/(String)vAddtlCost.elementAt(iLoop+3)%></td>
      <td class="thinborder"><div align="right"><%=/*strTemp2+*/(String)vAddtlCost.elementAt(iLoop+4)%></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="19%" height="25"><strong>CANVASSED BY : </strong>&nbsp;</td>
      <td width="27%" class="thinborderBottom">&nbsp;</td>
      <td width="54%">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="req_index" value="<%=strReqIndex%>">
</form>
<script language="JavaScript">
	window.setInterval("javascript:window.print()",0);
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
