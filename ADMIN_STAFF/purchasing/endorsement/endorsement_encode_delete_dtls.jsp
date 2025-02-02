<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function OpenSearchPO(){
	var pgLoc = "../purchase_order/purchase_request_view_search.jsp?opner_info=form_.req_no";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ProceedClicked(){    
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex,strCount){
	if(strAction == 0){
		var vProceed = confirm('Delete Item # '+strCount+' ?');
		if(vProceed){
			document.form_.printPage.value = "";
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			document.form_.proceedClicked.value = "1";
			this.SubmitOnce('form_');
		}
	}
	else{
		document.form_.printPage.value = "";
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		document.form_.proceedClicked.value = "1";
		this.SubmitOnce('form_');
	}	
}
function PageLoad(){
	document.form_.req_no.focus();
}

function CheckAll()
{
	document.form_.printPage.value = "";
	var iMaxDisp = document.form_.max_display.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i < eval(iMaxDisp);++i)
			eval('document.form_.endorse_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i < eval(iMaxDisp);++i)
			eval('document.form_.endorse_'+i+'.checked=false');
}

</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.Endorsement,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="endorsement_dtls_view_print.jsp"/>
	<%}
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
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
								"Admin/staff-PURCHASING-ENDORSEMENT-Delete Endorsement details","endorsement_encode_delete_dtls.jsp");
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
	
	Endorsement EN = new Endorsement();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItemsPO = null;
	Vector vReqItemsEn = null;	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	int iLoop = 0;
	int iCount = 0;
	int iItems = 1;
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = EN.operateOnReqInfoEn(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = EN.getErrMsg();
		else{
			if(WI.fillTextValue("pageAction").length() > 0){
				vRetResult = EN.operateOnLogEndorsement(dbOP,request,Integer.parseInt(WI.fillTextValue("pageAction")),(String)vReqInfo.elementAt(0));
				if(vRetResult == null)
					strErrMsg = EN.getErrMsg();
			}
			vRetResult = EN.operateOnLogEndorsement(dbOP,request,4,(String)vReqInfo.elementAt(0));
			if(vRetResult == null)
				strErrMsg = EN.getErrMsg();
			else{
				vReqItemsPO = (Vector)vRetResult.elementAt(0);
				vReqItemsEn = (Vector)vRetResult.elementAt(1);				
			}			
		}	
	}
%>
<form name="form_" method="post" action="endorsement_encode_delete_dtls.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENDORSEMENT - ENCODE/DELETE ENDORSEMENT DETAILS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">PO No. :</td>
      <td width="27%"> 
			<%if(WI.fillTextValue("req_no").length() > 0)
	  		strTemp = WI.fillTextValue("req_no");
	    else
	  		strTemp = "";
        %> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="50%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25" colspan="2"> <a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"> 
        </a></td>
    </tr>
    <%if(vReqInfo != null && vReqInfo.size() > 2){%>
    <tr> 
      <td height="25"> 
      <td>PO No. : <strong><%=(String)vReqInfo.elementAt(1)%></strong></td>
      <td><div align="center">PO Date : <strong><%=(String)vReqInfo.elementAt(2)%></strong> </div></td>
      <td colspan="2">PO Status :<strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(3))]%></strong></td>
    </tr>
    <%}%>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="19">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td height="26" colspan="5"><div align="center"><strong>REQUISITION DETAILS FOR THIS PURCHASE ORDER</strong></div></td>
    </tr>
    <tr>
      <td height="25" width="4%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(10)) == null){%>	
    <tr>
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
	<%}%>		
  </table>
  <%if((vReqItemsPO != null && vReqItemsPO.size() > 3) || 
       (vReqItemsEn != null && vReqItemsEn.size() > 3)){%>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>		
      <td height="30" colspan="8" align="right"><a href="javascript:PrintPage();"> 
        <img src="../../../images/print.gif" border="0"></a> <font size="1">click 
          to PRINT this endorsement record</font></td>
  	</tr>  
  </table>  
  <%}if(vReqItemsPO != null && vReqItemsPO.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
          OF PO  ITEM(S) DELIVERED </strong></font></td>
    </tr>
    <tr> 
      <td width="7%" height="40" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></td>
      <td width="9%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>TOTAL PRICE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>ENDORSE All <br>
        <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
      </strong></td>
    </tr>
	<%for(iLoop = 1,iCount = 1;iLoop < vReqItemsPO.size();iLoop+=12,++iCount,++iItems){%>
    <tr> 
      <td height="26" align="center" class="thinborder"><%=iCount%></td>
      <%
				strTemp = (String)vReqItemsPO.elementAt(iLoop+10);
			%>			
      <td align="right" class="thinborder">
				<input type="hidden" name="po_qty_<%=iCount%>" value="<%=(String)vReqItemsPO.elementAt(iLoop+1)%>">
        <input type="hidden" name="logged_qty_<%=iCount%>" value="<%=(String)vReqItemsPO.elementAt(iLoop+9)%>">
				<input type="hidden" name="endorsed_qty_<%=iCount%>" value="<%=(String)vReqItemsPO.elementAt(iLoop+11)%>">
			<input name="add_endorse_qty_<%=iCount%>" type="text" class="textbox" tabindex="-1" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
				value="<%=strTemp%>" size="3" maxlength="10" style="text-align:right">
			&nbsp;</td>
      <td align="center" class="thinborder"><%=vReqItemsPO.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=vReqItemsPO.elementAt(iLoop+3)%> / <%=vReqItemsPO.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItemsPO.elementAt(iLoop+8),"(",")","")%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsPO.elementAt(iLoop+6),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsPO.elementAt(iLoop+7),"&nbsp;")%></td>
      <td class="thinborder"><div align="center">
	  <%			
			if (!((String)vReqInfo.elementAt(3)).equals("1")  || // not approved
					 ((String)vReqItemsPO.elementAt(iLoop+5)).equals("0") || // not received 
					 ((String)vReqItemsPO.elementAt(iLoop+5)).equals("3") ){// returned
					 
					 %> 
	  		N/A
			<input type="hidden" name="endorse_<%=iCount%>" value="0">
	  <%}else{%>
	  		<input type="checkbox" name="endorse_<%=iCount%>" value="1">
	  <%}%>
	  <input type="hidden" name="strPOItemIndex_<%=iCount%>" value="<%=vReqItemsPO.elementAt(iLoop)%>">
	  </div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL 
        ITEM(S) : <%=iCount-1%>
        <input type="hidden" name="numOfItems" value="<%=iCount-1%>">
      </strong></td>
      <td height="25" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td align="right" class="thinborder"><strong><%=WI.getStrValue(vReqItemsPO.elementAt(0),"&nbsp;")%></strong></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
	    <tr> 
        <td height="25" colspan="98">&nbsp;</td>
	    </tr>
  </table>
  <%}if(vReqItemsEn != null && vReqItemsEn.size() > 3){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
        OF PO ITEM(S) ENDORSED</strong></font></td>
    </tr>
    <tr> 
      <td width="7%" height="27" align="center" class="thinborder"><strong>ITEM#</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>TOTAL PRICE</strong></td>
			<%if(false){%>
      <td width="9%" align="center" class="thinborder"><strong>DELETE</strong></td>
			<%}%>
    </tr>
    <%for(iLoop = 1,iCount = 1;iLoop < vReqItemsEn.size();iLoop+=12,++iCount){%>
    <tr> 
      <td height="26" align="center" class="thinborder"><%=iCount%></td>
      <td align="right" class="thinborder"><%=vReqItemsEn.elementAt(iLoop+10)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vReqItemsEn.elementAt(iLoop+2)%></td>
      <td class="thinborder"><%=vReqItemsEn.elementAt(iLoop+3)%> / <%=vReqItemsEn.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItemsEn.elementAt(iLoop+8),"(",")","")%>      </td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsEn.elementAt(iLoop+6),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vReqItemsEn.elementAt(iLoop+7),"&nbsp;")%></td>
			<%if(false){%>
      <td class="thinborder"><div align="center"> 
				<%if(((String)vReqItemsEn.elementAt(iLoop+9)).equals("0")){%>
	      <a href="javascript:PageAction(0,'<%=vReqItemsEn.elementAt(iLoop)%>',<%=iCount%>);"> 
          <img src="../../../images/delete.gif" border="0"></a>
				<%}else{%>
					Logged
				<%}%>
					</div></td>
			<%}%>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL 
        ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></td>
      <td height="25" align="right" class="thinborder"><strong>TOTAL 
      AMOUNT : </strong></td>
      <td align="right" class="thinborder"><strong><%=WI.getStrValue(vReqItemsEn.elementAt(0),"&nbsp;")%></strong></td>
			<%if(false){%>
      <td class="thinborder">&nbsp;</td>
			<%}%>
    </tr>
    <tr> 
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(vReqItemsPO != null && vReqItemsPO.size() > 3){%>
    <tr> 
      <td height="25" colspan="8"><div align="center"> <a href="javascript:PageAction(1,0,0);"> 
          <img src="../../../images/save.gif" border="0"> </a> <font size="1">click 
          to SAVE items endorsed</font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->  
  <input type="hidden" name="max_display" value ="<%=iItems%>">
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
