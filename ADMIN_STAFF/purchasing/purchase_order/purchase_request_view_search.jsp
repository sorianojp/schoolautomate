<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	///added code for HR/companies.
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
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
    document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}
function ViewItem(strIndex){
	var pgLoc = "purchase_request_view.jsp?req_no="+strIndex+'&isForPO=1';
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
<%if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID)
{
	window.opener.document.<%=strFormName%>.proceedClicked.value=1;
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;	
	window.opener.focus();
	<%
	if(strFormName != null){%>	
	window.opener.document.<%=strFormName%>.submit();	
	<%}%>	
	self.close();
}<%}%>
</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./purhase_request_view_search_print.jsp"/>
	<%}
 	
//add security here.
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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
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
								"Admin/staff-PURCHASING-PURCHASE ORDER-View PO","purchase_request_view_search.jsp");
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
	PO PO = new PO();
	Vector vRetResult = null;
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String strCollDiv = null;
	if(bolIsSchool)
		 strCollDiv = "College";
	else
		 strCollDiv = "Division";	
	String[] astrSortByName    = {"PO No.","PO Status",strCollDiv,"Department"};
	String[] astrSortByVal     = {"PO_NUMBER","PO_STATUS","C_CODE","D_name"};
	int iSearch = 0;
	int iDefault = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = PO.operateOnSearchListPO(dbOP,request);
		if(vRetResult == null)
			strErrMsg = PO.getErrMsg();
		else
			iSearch = PO.getSearchCount();
	}
	
%>
<form name="form_" method="post" action="purchase_request_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
	<% if (WI.fillTextValue("is_cancel").equals("1")){%>    
	<td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - CANCELLED PO PAGE ::::</strong></font></div></td>
    </tr>
	<%}else{%>
	<tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - APPROVED PO PAGE ::::</strong></font></div></td>
    </tr>
	<%}%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="15%" height="25">PO No. : </td>
      <td width="40%" height="25"> <select name="po_no_select">
          <%=PO.constructGenericDropList(WI.fillTextValue("po_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="18%">Status : </td>
      <td width="26%"><select name="status">
          <option value="">All</option>
          <%if(WI.fillTextValue("status").equals("2")){%>
          <option value="1">Approved</option>
          <option value="2" selected>Pending</option>
          <option value="0">Disapproved</option>
          <%}else if(WI.fillTextValue("status").equals("0")){%>
          <option value="1">Approved</option>
          <option value="2">Pending</option>
          <option value="0" selected>Disapproved</option>
          <%}else if(WI.fillTextValue("status").equals("1")){%>
          <option value="1" selected>Approved</option>
          <option value="2">Pending</option>
          <option value="0">Disapproved</option>
          <%}else{%>
          <option value="1">Approved</option>
          <option value="2">Pending</option>
          <option value="0">Disapproved</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Requisition No. : </td>
      <td height="25"> <select name="req_no_select">
          <%=PO.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td height="25">Budget :</td>
      <td height="25"><select name="budget">
          <option value="">All</option>
          <%if(WI.fillTextValue("budget").equals("0")){%>
          <option value="1">Within Budget</option>
          <option value="0" selected>Not in the Budget</option>
          <%}else if(WI.fillTextValue("budget").equals("1")){%>
          <option value="1" selected>Within Budget</option>
          <option value="0">Not in the Budget</option>
          <%}else{%>
          <option value="1">Within Budget</option>
          <option value="0">Not in the Budget</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Requested by :</td>
      <td height="25"><select name="req_by_select">
          <%=PO.constructGenericDropList(WI.fillTextValue("req_by_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_by" class="textbox" value="<%=WI.fillTextValue("req_by")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td height="25">Payment Charge to:</td>
      <td height="25"> <% if(WI.fillTextValue("fund").length() > 0)
	  		strTemp = WI.fillTextValue("fund");
		 else
			strTemp = "";
	  %> 
	  <select name="fund">
      	<option value="">All</option>
        	<%=dbOP.loadCombo("FUND_INDEX","FUND_NAME"," from PUR_PRELOAD_FUND order by FUND_NAME asc", strTemp, false)%> 
	  </select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%> :</td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%if(WI.fillTextValue("c_index").equals("0")){%>
          <option value="0" selected>Non-Academic Office</option>
          <%}else{%>
          <option value="0">Non-Academic Office</option>
          <%} 
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp = WI.fillTextValue("c_index");
			else
				strTemp = "0";
			
			if(strTemp.compareTo("0") ==0)
				strTemp2 = "Offices";
			else
			strTemp2 = "Department";
			%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td colspan="3"> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <option value="0">All</option>
          <%if(WI.fillTextValue("c_index").length() < 1)
				strTemp = "-1";
			else
				strTemp3 = WI.fillTextValue("d_index");
		%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>PO DATE</td>
      <td colspan="3">
        <%strTemp = WI.fillTextValue("po_date_fr");%>
        <input name="po_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.po_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("po_date_to");%>
        <input name="po_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.po_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Supplier</td>
      <td colspan="3">
	  <select name="supplier_r" style="font-size:11px;">
      	<option value="">All</option>
<%
strTemp = " from PUR_SUPPLIER_PROFILE where is_del = 0 and exists (select * from pur_po_item where pur_po_item.supplier_index = PUR_SUPPLIER_PROFILE.profile_index) "+
			"order by supplier_name";
%>
        	<%=dbOP.loadCombo("profile_index","supplier_name",strTemp, WI.fillTextValue("supplier_r"), false)%> 
	  </select>
	  </td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="0" height="26">&nbsp;</td>
      <td colspan="4"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="8">&nbsp;</td>
      <td width="24%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=PO.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=PO.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select></td>
      <td width="24%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=PO.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td><select name="sort_by4">
          <option value="">N/A</option>
          <%=PO.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="4"><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0" ></a> 
      </td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(!(WI.fillTextValue("opner_info").length() > 0)){%>
    <tr> 
      <td height="28" colspan="2"><div align="right">Number of PO(s) Per Page: 
          <select name="num_stud_page">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPage();"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1"> click to print list&nbsp;</font></div></td>
    </tr>
	<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=PO.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/PO.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % PO.defSearchSize > 0) ++iPageCount;		
		if(iPageCount >= 1)
		{%>
		&nbsp;</td>
		
      <td> <div align="right">Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
		%>
          </select>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" colspan="2" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PURCHASE ORDER(S)</strong></font></div></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><strong>PO DATE</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><strong>PO NO.</strong></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>REQUISITION NO.</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> / 
          DEPT</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>OFFICE</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>PO STATUS</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>TOTAL ITEMS </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>TOTAL AMOUNT</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>VIEW</strong></div></td>
    </tr>
    <%for(int iLoop = 1;iLoop < vRetResult.size();iLoop+=10){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="center"> 
          <%if(WI.fillTextValue("opner_info").length() > 0) {%>
          <a href="javascript:CopyID('<%=(String)vRetResult.elementAt(iLoop+3)%>');"> 
          <%=(String)vRetResult.elementAt(iLoop+3)%></a> 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop+3)%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="center"> <%=(String)vRetResult.elementAt(iLoop+4)%> </div></td>
      <td class="thinborder"> <div align="left">
          <%if(((String)vRetResult.elementAt(iLoop+5)) != null){%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+5),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"All")%> 
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td class="thinborder"> <div align="left">
          <%if(((String)vRetResult.elementAt(iLoop+5)) != null){%>
          N/A 
          <%}else{%>
          <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"&nbsp;")%> 
          <%}%>
        </div></td>
      <td class="thinborder"><div align="left"><%=astrPOStatus[Integer.parseInt((String)vRetResult.elementAt(iLoop+7))]%></div></td>
      <td class="thinborder"><div align="center">
	  	  <%if(vRetResult.elementAt(iLoop+8) == null || ((String)vRetResult.elementAt(iLoop+8)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=(String)vRetResult.elementAt(iLoop+8)%> 
          <%}%>
	  </div></td>
      <td class="thinborder"><div align="right">
        <%if(vRetResult.elementAt(iLoop+9) == null || ((String)vRetResult.elementAt(iLoop+9)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+9),true)%>
		<%}%>
      </div></td>
      <td class="thinborder"><div align="center"> 
          <%if(!(WI.fillTextValue("opner_info").length() > 0) && !(WI.fillTextValue("is_cancel").equals("1"))){%>
          <a href="javascript:ViewItem('<%=(String)vRetResult.elementAt(iLoop+3)%>');"> 
          <img src="../../../images/view.gif" border="0" ></a> 
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
    </tr>
    <%  if(((String)vRetResult.elementAt(iLoop+8)) != null && ((String)vRetResult.elementAt(iLoop+8)).length() > 0)
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(iLoop+8));    
		
		if(((String)vRetResult.elementAt(iLoop+9)) != null && ((String)vRetResult.elementAt(iLoop+9)).length() > 0)
			dTotalAmount += Double.parseDouble((String)vRetResult.elementAt(iLoop+9));
	}if(!(WI.fillTextValue("opner_info").length() > 0)){%>
    <tr> 
      <td  height="25" colspan="6" class="thinborder"> <div align="right"><strong>PAGE 
          TOTAL :&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td class="thinborder"><div align="center"><strong><%=CommonUtil.formatFloat(dTotalItems,false)%></strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></div></td>
      <td rowspan="2" class="thinborder">&nbsp;</td>
    </tr>
	<tr>
    <td class="thinborder" height="25" colspan="6"><div align="left"></div>
      <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp; &nbsp;&nbsp;</strong></div></td>
    <td height="25" colspan="2" class="thinborder"><div align="right"></div>
      <div align="right"><strong><%=CommonUtil.formatFloat(WI.getStrValue((String)vRetResult.elementAt(0),"0"),true)%></strong></div></td>
  	</tr>
	<%}%>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
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
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="isForPO" value="1">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
  <input type="hidden" name="is_cancel" value="<%=WI.fillTextValue("is_cancel")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
