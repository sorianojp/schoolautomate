<%@ page language="java" import="utility.*,purchasing.Endorsement,java.util.Vector" %>
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ProceedClicked(){
	document.form_.printPage.value = "";
	document.form_.proceedClicked.value = "1";
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
function ViewItem(strIndex){
	var pgLoc = "endorsement_dtls_view.jsp?req_no="+strIndex;
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
		<jsp:forward page="./endorsement_view_search_print.jsp"/>
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
								"Admin/staff-PURCHASING-ENDORSEMENT-Search Endorsement","endorsement_view_search.jsp");
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
	Vector vRetResult = null;
	String[] astrPOStatus = {"Disapproved","Approved","Pending"};
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String strCollDiv = null;
	if(bolIsSchool)
		 strCollDiv = "College";
	else
		 strCollDiv = "Division";	
	String[] astrSortByName    = {"PO No.","Requisition No.",strCollDiv,"Department"};
	String[] astrSortByVal     = {"PO_NUMBER","REQUISITION_NO","C_CODE","D_NAME"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	int iSearch = 0;
	int iDefault = 0;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = EN.operateOnSearchListEn(dbOP,request);
		if(vRetResult == null)
			strErrMsg = EN.getErrMsg();
		else
			iSearch = EN.getSearchCount();		
	}
%>
<form name="form_" method="post" action="endorsement_view_search.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENDORSEMENT - SEARCH/VIEW ENDORSEMENT RECORD PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25">PO No. : </td>
      <td width="82%" height="25"> <select name="po_no_select">
          <%=EN.constructGenericDropList(WI.fillTextValue("po_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="po_no" class="textbox" value="<%=WI.fillTextValue("po_no")%>"
	       onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Requisition No. : </td>
      <td height="25"> <select name="req_no_select">
          <%=EN.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Requested by :</td>
      <td height="25"><select name="req_by_select">
          <%=EN.constructGenericDropList(WI.fillTextValue("req_by_select"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="req_by" class="textbox" value="<%=WI.fillTextValue("req_by")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=strCollDiv%> :</td>
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
    <tr>
      <td height="27">&nbsp;</td>
      <td>Endorsement w/ Returns  : </td>
			<%
				strTemp = WI.fillTextValue("reason_index");
			%>
      <td><select name="reason_index">
        <option value="">Select Reason</option>
        <%=dbOP.loadCombo("reason_index","reason"," from pur_preload_reason order by reason", strTemp, false)%>
      </select></td>
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
          <%=EN.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=EN.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td width="24%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=EN.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
      <td><select name="sort_by4">
          <option value="">N/A</option>
          <%=EN.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select></td>
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
	  	<strong><font size="1">TOTAL RESULT : <%=iSearch%>- Showing(<%=EN.getDisplayRange()%>)</font></strong>
     <%
		int iPageCount = iSearch/EN.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % EN.defSearchSize > 0) ++iPageCount;		
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
          OF ENDORSEMENTS</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="11%" height="25" align="center" class="thinborder"><strong>PO NO.</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>REQUISITION NO.</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>COLLEGE / 
        DEPT</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>NON-ACAD 
        OFFICE/DEPT</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>TOTAL ITEMS </strong></td>
      <td width="8%" align="center" class="thinborder"><strong>RETURNS</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>TOTAL AMOUNT</strong></td>
      <td width="6%" align="center" class="thinborder"><strong>VIEW</strong></td>
    </tr>
    <%for(int iLoop = 1;iLoop < vRetResult.size();iLoop+=9){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(iLoop+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(iLoop+3)%></td>
      <td class="thinborder">&nbsp; 
        <%if(((String)vRetResult.elementAt(iLoop+4)) != null){%>
        <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+4),"N/A") +"/"+ WI.getStrValue((String)vRetResult.elementAt(iLoop+5),"All")%>  
        <%}else{%>
         N/A 
        <%}%>        </td>
      <td class="thinborder">&nbsp; 
        <%if(((String)vRetResult.elementAt(iLoop+4)) != null){%>
        N/A 
        <%}else{%>
        <%=WI.getStrValue((String)vRetResult.elementAt(iLoop+5),"&nbsp;")%> 
        <%}%>        </td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"&nbsp;")%> </div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+8),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+7),true)%></div></td>
      <td class="thinborder"><div align="center"><a href="javascript:ViewItem('<%=(String)vRetResult.elementAt(iLoop+2)%>');"><img src="../../../images/view.gif" border="0" ></a></div></td>
    </tr>
    <%  if(((String)vRetResult.elementAt(iLoop+6)) != null && ((String)vRetResult.elementAt(iLoop+6)).length() > 0)
			dTotalItems += Double.parseDouble((String)vRetResult.elementAt(iLoop+6));    
		
		if(((String)vRetResult.elementAt(iLoop+7)) != null && ((String)vRetResult.elementAt(iLoop+7)).length() > 0)
			dTotalAmount += Double.parseDouble((String)vRetResult.elementAt(iLoop+7));
	}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"> <div align="right"><strong>PAGE 
          TOTAL :&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotalItems,false)%></div></td>
      <td class="thinborder">&nbsp;</td>
      <td height="25" class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTotalAmount,true)%></div></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <td  class="thinborder" height="25" colspan="4"><div align="left"></div>
      <div align="right"><strong>OVERALL SEARCH TOTAL :&nbsp; &nbsp;&nbsp;</strong></div></td>
    <td height="25" colspan="3"  class="thinborder"><div align="right"></div>
      <div align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(0),true)%></div></td>
    <td class="thinborder">&nbsp;</td>
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
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
