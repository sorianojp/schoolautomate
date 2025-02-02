<%@ page language="java" import="utility.*,purchasing.Canvassing,purchasing.Requisition,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);

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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function OpenSearch(){
	document.form_.print_pg.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&is_supply=form_.is_supply";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	//var selectedIndex = null;
	if(document.form_.supplier1){
		document.form_.supplier_name1.value = document.form_.supplier1[document.form_.supplier1.selectedIndex].text;
		document.form_.supplier_name2.value = document.form_.supplier2[document.form_.supplier2.selectedIndex].text;
		document.form_.supplier_name3.value = document.form_.supplier3[document.form_.supplier3.selectedIndex].text;
		document.form_.supplier_name4.value = document.form_.supplier4[document.form_.supplier4.selectedIndex].text;
		document.form_.supplier_name5.value = document.form_.supplier5[document.form_.supplier5.selectedIndex].text;
	}
	document.form_.print_pg.value = "";
	document.form_.proceedClicked.value = 1;		
	this.SubmitOnce('form_');
}
function PrintPg(){	
	var vCheck = true;
	var iCount = 0;
	for(iCount = 1;iCount < 6;iCount++){		
		if(eval('document.form_.supplier'+iCount+'.value.length') > 0){
			vCheck = false;
			break;
		}		
	}
	
	if(vCheck){
		alert('Select Supplier');
		return;
	}
	document.form_.print_pg.value = 1;
	this.SubmitOnce('form_');
}
function SaveClicked(){
	document.form_.print_pg.value = "";
	document.form_.save_clicked.value = 1;
	this.SubmitOnce('form_');
}
function CancelClicked(){
	location = "./print_canvassing2.jsp";
}
</script>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	

	if(WI.fillTextValue("print_pg").equals("1")){
		if(strSchCode.startsWith("VMA")){
	%>
		<jsp:forward page="../requisition/req_item_print_vma.jsp"/>
	<%}else{%>
		<jsp:forward page="./print_canvassing2_print.jsp"/>
	<%}
	}

	DBOperation dbOP = null;
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-CANVASSING"),"0"));
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
								"Admin/staff-PURCHASING-CANVASSING-Print Canvassing","print_canvassing.jsp");
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
	Canvassing CAN = new Canvassing();	
	Vector vReqInfo = null;
	Vector vReqItems = null;	
	Vector vReqCanvass = null;
	boolean bolIsInCanvass = false;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};

	String strInfoIndex = WI.fillTextValue("info_index");
	String strCanvassNo = WI.fillTextValue("canvass_no");
	String strCanvassDate = WI.fillTextValue("canvass_date");
	String[] astrSuppliers = new String[5];
	
	int iTemp = 1;
	int j = 0;
	for(int i = 0; i < 5; i++){
		strTemp = WI.fillTextValue("supplier"+(i+1));		
		for(j = 1; j < 6;j++){
			strTemp2 = WI.fillTextValue("supplier"+j);
			if(strTemp.equals(strTemp2))
				continue;
				
			if(astrSuppliers[i] == null || astrSuppliers[i].length() == 0)
				astrSuppliers[i] = strTemp2;
			else
				astrSuppliers[i] = astrSuppliers[i] + WI.getStrValue(strTemp2,",","","");
		}
	}
	
	int iDefault = 0;	
	if (WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null)
			strErrMsg = REQ.getErrMsg();
		else{
			strInfoIndex = (String)vReqInfo.elementAt(0);
			if(WI.fillTextValue("save_clicked").length() > 0){
				vReqItems = CAN.saveCanvass(dbOP,request,strInfoIndex);
				if(vReqItems == null)
					strErrMsg = CAN.getErrMsg();
				else
					strErrMsg = "Operation Successful.";
			}
			vReqCanvass = CAN.getCanvassInfo(dbOP,strInfoIndex);
			if(vReqCanvass == null)
				strErrMsg = CAN.getErrMsg();
			else if(vReqCanvass.size() > 0){
				bolIsInCanvass = true;
				strCanvassNo = (String)vReqCanvass.elementAt(0);
				strCanvassDate = (String)vReqCanvass.elementAt(1);
			}
				
			vReqItems = REQ.operateOnReqItems(dbOP,request,5);
			if(vReqItems == null)
				strErrMsg = REQ.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<form name="form_" method="post" action="./print_canvassing2.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CANVASSING - PRINT REQUISITION FOR CANVASSING PAGE ::::</strong></font></div></td>
    </tr>	
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%">Requisition No. :</td>
      <td width="25%"> 
	  <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="44%">
	   <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search requisition no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">
	  <%if(bolIsInCanvass){%>
	  <a href="../quotation/quotation_encode.jsp?proceedClicked=1&req_no=<%=strCanvassNo%>">Click here to encode Quotation</a>
	  <%}%>&nbsp;	  
	  </td>
      <td height="25" colspan="2"><a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"></a><a href="javascript:OpenSearchPO();"> </a></td>
    </tr>
    <%if(bolIsInCanvass){%>
    <tr> 
      <td height="25"> 
      <td>Canvassing No.: <strong><%=strCanvassNo%></strong></td>
      <td colspan="2">Canvassing Date : <strong><%=strCanvassDate%></strong></td>
    </tr>    
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<%}%>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
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
      <td>Non-Acad. Office/Dept :</td>
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
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">
        <a href="print_canvassing.jsp?proceedClicked=1&req_no=<%=WI.fillTextValue("req_no")%>">Click here to go to other format</a>
      </td>
    </tr>
  </table>
	<%if(bolIsInCanvass){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="19" colspan="3">SUPPLIERS:</td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 1 </td>
			<%				
				strTemp = WI.fillTextValue("supplier1");
			%>
      <td width="83%" height="19"><select name="supplier1" onChange="ProceedClicked('1');">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_NAME"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[0],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 2 </td>
			<%				
				strTemp = WI.fillTextValue("supplier2");
			%>
      <td width="83%" height="19"><select name="supplier2" onChange="ProceedClicked();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_NAME"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[1],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 3</td>
			<%				
				strTemp = WI.fillTextValue("supplier3");
			%>
      <td width="83%" height="19"><select name="supplier3" onChange="ProceedClicked();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_NAME"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[2],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 4</td>
			<%				
				strTemp = WI.fillTextValue("supplier4");
			%>
      <td width="83%" height="19"><select name="supplier4" onChange="ProceedClicked();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_NAME"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[3],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>		
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 5</td>
			<%				
				strTemp = WI.fillTextValue("supplier5");
			%>
      <td width="83%" height="19"><select name="supplier5" onChange="ProceedClicked();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_NAME"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[4],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">&nbsp;</td>
      <td height="19">&nbsp;</td>
    </tr>				
  </table>	
	<%}%>
  <%if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <%if(bolIsInCanvass){%>
    <tr>
      <td class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>	  
      <%
			for(j = 1; j < 6; j++){
				if(WI.fillTextValue("supplier"+j).length() == 0)
					continue;
			%>
			<td colspan="3" align="center" class="thinborder">&nbsp;<%=WI.fillTextValue("supplier_name"+j)%></td>
			<%}%>
    </tr>
		<%}%>
    <tr>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>ITEM 
      / PARTICULARS / DESCRIPTION </strong></font></td> 
      <td width="12%" height="26" align="center" class="thinborder"><font size="1"><strong>QTY</strong></font> / <font size="1"><strong>UNIT</strong></font></td>	  
			<%
			for(j = 1; j < 6; j++){
				if(WI.fillTextValue("supplier"+j).length() == 0)
					continue;
			%>
      <td align="center" class="thinborder"><font size="1"><strong>REG PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DISC PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL AMT</strong></font></td>
			<%}%>
    </tr>
    <%for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){%>
    <tr>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop+3)%>/<%=(String)vReqItems.elementAt(iLoop+4)%></td>
      <td height="25" class="thinborder"><%=(String)vReqItems.elementAt(iLoop+1)%>&nbsp;<%=(String)vReqItems.elementAt(iLoop+2)%></td>
			<%
			for(j = 1; j < 6; j++){
				if(WI.fillTextValue("supplier"+j).length() == 0)
					continue;
			%>			
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
			<%}%>
    </tr>
    <%}%>
  </table>	
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%if(!bolIsInCanvass && vReqItems != null && vReqItems.size() > 3){%>
	<tr>
      <td height="25"><div align="center"> <a href="javascript:SaveClicked();"><img src="../../../images/save.gif" border="0"></a> <font size="1">click to SAVE Requisition for Canvassing </font> 
          <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click to cancel</font></div></td>
    </tr>
    <%}else if(bolIsInCanvass && vReqItems != null && vReqItems.size() > 3){%>
	<tr> 
      <td height="25"><div align="center">          
	     <%if (!strSchCode.startsWith("UI")){%>
          <font size="1">Items per page</font> 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <%}else{%>
          <input type="hidden" name="num_rows" value="15">
          <%}%>
		  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to PRINT Requisition for Canvassing</font></div></td>
    </tr>
	<%}%>
  </table>
  <%}%>
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
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("pageAction")%>">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="save_clicked" value="">  
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="is_canvass" value="1">
  <input type="hidden" name="canvass_no" value="<%=strCanvassNo%>">
  <input type="hidden" name="canvass_date" value="<%=strCanvassDate%>">
	<input type="hidden" name="supplier_name1" value="<%=WI.fillTextValue("supplier_name1")%>">
	<input type="hidden" name="supplier_name2" value="<%=WI.fillTextValue("supplier_name2")%>">
	<input type="hidden" name="supplier_name3" value="<%=WI.fillTextValue("supplier_name3")%>">
	<input type="hidden" name="supplier_name4" value="<%=WI.fillTextValue("supplier_name4")%>">
	<input type="hidden" name="supplier_name5" value="<%=WI.fillTextValue("supplier_name5")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
