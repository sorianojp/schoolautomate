<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
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
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function SaveClicked(){
	document.form_.print_pg.value = "";
	document.form_.saveClicked.value = "1";
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./request_update_entries.jsp";
}

function OpenSearch(){
	document.form_.print_pg.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}

function EditRequest(strReqIndex,strReqItemIndex){
	document.form_.print_pg.value = "";
	var pgLoc = "./request_pop_up.jsp?req_index="+strReqIndex+"&isForPop=1&req_item_index="+strReqItemIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="request_update_entries_print.jsp"/>
	<%return;}

//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-PURCHASE ORDER","request_update_entries.jsp");
	Requisition REQ = new Requisition();
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItems = null;
	Vector vSelItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrQuoteUnit = {"(per unit)","(whole order)"};
	String strErrMsg = null;
	String strTemp1 = null;
	String strTemp2 = null;
	String strInfoIndex = WI.fillTextValue("info_index");	
	int iLoop = 0;
	String strReqIndex  = null;
	double dTotalAmount  = 0d;
	int iRowCount = 0;

	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = REQ.getErrMsg();
		else{
			strReqIndex = (String)vReqInfo.elementAt(0);
			vRetResult = REQ.operateOnNonPOReqItems(dbOP,request);	
			if(vRetResult != null && vRetResult.size() > 0)	{
				vReqItems = (Vector) vRetResult.elementAt(0);
				vSelItems = (Vector) vRetResult.elementAt(1);
			}
		if(((vReqItems == null || vReqItems.size() < 1) && (vSelItems == null || vSelItems.size() == 0)) && strErrMsg == null)
			strErrMsg = "No item encoded for this Requisition.";					
		}
	}	


%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="./request_update_entries.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUISITION - UPDATE REQUISITION ENTRIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%">REQUISITION NO. :</td>
      <td width="25%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp1 = WI.fillTextValue("req_no");
	  }else{
	  		strTemp1 = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp1%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="44%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search requisition no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr> 
  </table>
<%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS</strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(12)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(3)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}%>
	<tr> 
      <td height="26" colspan="6">&nbsp;</td>      
    </tr>	
  </table>
  <%if((vReqItems != null && vReqItems.size() > 0) || (vSelItems != null && vSelItems.size() > 0)){%>
  <%if(vReqItems != null && vReqItems.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder" bgcolor="B9B292"><div align="center"><font color="#FFFFFF"><strong>REQUISITION 
          ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%"  height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/DESCRIPTION 
          </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>EDIT</strong>&nbsp;</div></td>
    </tr>
    <% iRowCount = 0;
	for(iLoop = 0;iLoop < vReqItems.size();iLoop+=10,++iRowCount){
		
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+10)/10%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"> 
          <% //if(vReqItems.elementAt(iLoop+7) != null){
		  //dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	      %>
          <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="center"> <a href="javascript:EditRequest('<%=strReqIndex%>','<%=vReqItems.elementAt(iLoop+8)%>');"> 
          <img src="../../../images/edit.gif" border="0"></a> </div></td>
    </tr>
    <%}%>
    <input type="hidden" name="row_count" value="<%=iRowCount%>">
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/9%></strong></div>
        <div align="right"></div>
        <div align="right"></div></td>
    </tr>
  </table>
  <%}%>
  <%if(vSelItems != null && vSelItems.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder" bgcolor="B9B292"><div align="center"><font color="#FFFFFF"><strong>REQUISITION 
          ITEMS WITH SUPPLIER</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%"  height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/DESCRIPTION 
          </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>EDIT</strong>&nbsp;</div></td>
    </tr>
    <% iRowCount = 0;
	for(iLoop = 0;iLoop < vSelItems.size();iLoop+=10,++iRowCount){
		
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+10)/10%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vSelItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vSelItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vSelItems.elementAt(iLoop+1)%> / <%=(String)vSelItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vSelItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vSelItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vSelItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"> 
          <% //if(vReqItems.elementAt(iLoop+7) != null){
		  //dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	      %>
          <%if(vSelItems.elementAt(iLoop+7) == null || ((String)vSelItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vSelItems.elementAt(iLoop+7),true)%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="center"> <a href="javascript:EditRequest('<%=strReqIndex%>','<%=vSelItems.elementAt(iLoop+8)%>');"> 
          <img src="../../../images/edit.gif" border="0"></a> </div></td>
    </tr>
    <%}%>
    <input type="hidden" name="row_count" value="<%=iRowCount%>">
    <tr> 
      <td height="25" colspan="9" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vSelItems.size()/10%></strong></div>
        <div align="right"></div>
        <div align="right"></div></td>
    </tr>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" colspan="5"><div align="center">
	  <a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" border="0"></a><font size="1">click to print list</font>
	  </div></td>
    </tr>
  </table>
  <%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"><div align="center"> 
          <a href="javascript:CancelClicked();"> 
		  <img src="../../../images/go_back.gif" border="0"> 
          </a>
		  <font size="1">click to go back</font></div></td>
    </tr>
  </table>  
  <%}
  }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="isForEntry" value="1">
  <input type="hidden" name="saveClicked" value="">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="delete_cost">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
