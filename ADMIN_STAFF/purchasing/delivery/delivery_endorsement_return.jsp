<%@ page language="java" import="utility.*,purchasing.Returns,java.util.Vector" %>
<%
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage(){	
  document.form_.printPage.value = "";	
 	this.SubmitOnce('form_');
}

function ViewDetails(strReqNo, strSupplier, strIndex){
	var pgLoc = "delivery_returns_view.jsp?req_no="+strReqNo+"&supplier_code="+strSupplier+
							"&search_po=1&return_index="+strIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolFatalErr = true;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./delivery_endorse_return_print.jsp"/>
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
								"Admin/staff-PURCHASING-ENDORSEMENT-Search Returns","delivery_endorsement_return.jsp");
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
	
	Returns RET = new Returns();
	Vector vRetResult = null;
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String strCollDiv = null;
	if(bolIsSchool)
		 strCollDiv = "College";
	else
		 strCollDiv = "Division";	
	String[] astrSortByName    = {"PO No.",strCollDiv,"Department"};
	String[] astrSortByVal     = {"PO_NUMBER","C_CODE","D_NAME"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};
	
	int iSearch = 0;
	int iDefault = 0;
	boolean bolLooped = false;
	boolean bolSamePO = false;
	String strPrevPO = null;
//	String strPrevColl = null;
//	String strPrevDept = null;
	
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = RET.searchReturnEndorsement(dbOP,request);
		if(vRetResult == null)
			strErrMsg = RET.getErrMsg();
		else
			iSearch = RET.getSearchCount();		
	}
%>
<form name="form_" method="post" action="delivery_endorsement_return.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		<%
			if(WI.fillTextValue("is_from_endorsed").length() > 0)
				strTemp = "ENDORSEMENT - SEARCH/VIEW ENDORSEMENT RECORD PAGE";
			else
				strTemp = "ENDORSEMENT - SEARCH/VIEW RETURNS TO SUPPLIER PAGE";
			
		%>
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A">
				<div align="center"><font color="#FFFFFF"><strong>:::: <%=strTemp%> ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" height="25">PO No. : </td>
      <td width="81%" height="25"> <select name="po_no_select">
          <%=RET.constructGenericDropList(WI.fillTextValue("po_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	       onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Requisition No. : </td>
      <td height="25"> <select name="req_no_select">
          <%=RET.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Reason : </td>
      <%strTemp = WI.fillTextValue("reason_index");%>
			<td height="25">
			<select name="reason_index">
        <option value="">Select Reason</option>
        <%=dbOP.loadCombo("reason_index","reason"," from pur_preload_reason order by reason", strTemp, false)%>
      </select></td>
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
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td> <%String strTemp3 = null;
		if(strTemp.compareTo("0") ==0) //only if non college show others.
			strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
		else
			strTemp2 = "";
	  %> <select name="d_index">
          <option value="0">All</option>
      <%if(!WI.fillTextValue("c_index").equals("")){
		strTemp3 = "";
		if(bolFatalErr)
			strTemp3 = WI.fillTextValue("d_index");
	  %>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> 
          <%}%>
        </select></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" dwcopytype="CopyTableRow">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Returned Date</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="5%" height="25">&nbsp;</td>
      <td width="92%" height="25"> 
	    <%
			strTemp = WI.fillTextValue("return_for");
		%>
		<select name="return_for" onChange="ReloadPage();">
          <option value="0" selected>Specific Date</option>
          <%if (strTemp.equals("1")){%>		  
          <option value="1" selected>Date Range</option>
          <%}else{%>
          <option value="1">Date Range</option>
          <%}if (strTemp.equals("2")){%>
          <option value="2" selected>Year</option>
          <%}else{%>
          <option value="2">Year</option>
          <%}%>
      </select> </td>
    </tr>
    <%if(strTemp.equals("1")){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%strTemp = WI.fillTextValue("ret_fr");%> <input name="ret_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.ret_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <%strTemp = WI.fillTextValue("ret_to");%> <input name="ret_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.ret_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
    </tr>
    <%}else if(strTemp.equals("2")){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24"> 
	    <select name="ret_year" onChange="ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("ret_year"),2,1)%> 
		</select> 
		<%
			strTemp = WI.fillTextValue("ret_month");
		%>
		<select name="ret_month">
          <option value="">All</option>
          <%for(int i = 0; i < 12; ++i){%>
		  	<%if(strTemp.equals(Integer.toString(i+1))){%>
          		<option value="<%=i+1%>" selected><%=astrConvertMonth[i]%></option>
		  	<%}else{%>
		  		<option value="<%=i+1%>"><%=astrConvertMonth[i]%></option>
			<%}%>	
          <%}%>
        </select> </td>
    </tr>
    <%}else{%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%strTemp = WI.fillTextValue("ret_fr");%> <input name="ret_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <font size="1"><a href="javascript:show_calendar('form_.ret_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
    </tr>
     <%}%>
	<tr bgcolor="#FFFFFF">
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><a href="javascript:ReloadPage();"></a></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td colspan="4"><strong>Sort</strong></td>
    </tr>
    <tr> 
      <td height="8">&nbsp;</td>
      <td width="23%"><select name="sort_by1">
          <option value="">N/A</option>
      <%=RET.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=RET.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="24%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=RET.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="26%"><select name="sort_by4">
          <option value="">N/A</option>
      <%=RET.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
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
  <%if(vRetResult != null && vRetResult.size() > 3){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  	<tr> 
      <td height="10">
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=RET.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/RET.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % RET.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
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
		<%
			if(WI.fillTextValue("is_from_endorsed").length() > 0)
				strTemp = "LIST OF RETURNED ENDORSEMENTS";
			else
				strTemp = "LIST OF RETURNS TO SUPPLIER";
			
		%>
    <tr bgcolor="#B9B292" >			
      <td width="100%" height="25" colspan="2" class="thinborderTOPLEFTRIGHT">
				<div align="center"><font color="#FFFFFF"><strong><%=strTemp%></strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder"><strong>PO NO.</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>RETURN DATE </strong></td>
      <td width="32%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%> / 
        DEPT</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>SUPPLIER NAME</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>REASON/REMARKS</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>VIEW</strong></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=12){
				bolSamePO = false;
		%>
    <tr>
			<%
				//if(bolLooped && strPrevPO.equals((String)vRetResult.elementAt(i+9))
				//	&& strPrevRetIndex.equals((String)vRetResult.elementAt(i+12))){
				//	strTemp = "";
				//	bolSamePO = true;
				//}else
					strTemp = (String)vRetResult.elementAt(i+2);
			%>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
			<%
					strTemp = (String)vRetResult.elementAt(i+11);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%
				//if(bolSamePO){
				//	strTemp2 = "";
				//}else{
					if((String)vRetResult.elementAt(i + 3) == null || (String)vRetResult.elementAt(i + 4)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i + 3),"");
					strTemp2 += strTemp+ WI.getStrValue((String)vRetResult.elementAt(i + 4),"");
				//}				
			%>
			
      <td class="thinborder">&nbsp;<%=strTemp2%> </td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"0")%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
				strTemp2 = (String)vRetResult.elementAt(i+8);
				strTemp2 = WI.getStrValue(strTemp2,"");
				strTemp = WI.getStrValue(strTemp,"", "(" + strTemp2 + ")", "&nbsp;");
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td align="center" class="thinborder">
			<%if(!bolSamePO){%>
				<a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i+2)%>',
																				'<%=(String)vRetResult.elementAt(i+6)%>', 
																				'<%=(String)vRetResult.elementAt(i)%>');">
				<img src="../../../images/view.gif" border="0" ></a>
			<%}else{%>
			&nbsp;
			<%}%>			</td>
    </tr>
    <%bolLooped = true;
			strPrevPO = (String)vRetResult.elementAt(i + 1);			
			//strPrevColl = (String)vRetResult.elementAt(i + 10);
			//strPrevDept = (String)vRetResult.elementAt(i + 11);
		 }%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18">&nbsp;</td>
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
	<input type="hidden" name="is_from_endorsed" value="<%=WI.fillTextValue("is_from_endorsed")%>">
	<input type="hidden" name="req_no" value="<%=WI.fillTextValue("req_no")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
