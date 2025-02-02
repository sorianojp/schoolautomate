<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>

<script language="JavaScript">
function Search(){
	document.form_.search_.value = "1";
	document.form_.submit();
}
function PageAction(strPageAction, strIDNumber, strBarcode, bolReload) {
	document.form_.page_action.value = strPageAction;

	if(strPageAction == "0"){
		if(strBarcode.length == 0){
			alert("No barcode information.");
			return;
		}
	
		if(!confirm("Do you want to delete this barcode "+strBarcode+"?"))
			return;
			
		document.form_.parent_index.value = strIDNumber;
	}

	if(strIDNumber.length > 0 && strPageAction != "0") {
		document.form_.id_number2.value = strIDNumber;
		document.form_.bar_code2.value = strBarcode;		
	}
	
	
	
	if(bolReload)
		this.SubmitOnce("form_");
}

</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

boolean bolIsSchool = false;
int iSearchResult = 0;

Vector vRetResult = new Vector();
ParentRegistration parentReg = new ParentRegistration();


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Login ID","Lastname","Firstname"};
String[] astrSortByVal     = {"login_id","lname","fname"};


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){	
	if(parentReg.operateOnBarCode(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = parentReg.getErrMsg();
	else	
		strErrMsg = "Barcode information updated successfully.";
}


if(WI.fillTextValue("search_").length() > 0){
	vRetResult = parentReg.operateOnBarCode(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = parentReg.getErrMsg();
	else
		iSearchResult = parentReg.getSearchCount();
}

%>
<form action="./assign_rfid.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          RF ID MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
		<td width="25%" colspan="2" align="right"><a href="main.jsp"><img src="../../images/go_back.gif" border="0"></a></td>
	</tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Login ID</td>
      <td colspan="2"><input type="text" name="id_number2" value="<%=WI.fillTextValue("id_number2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">RF ID </td>
      <td colspan="2"><input type="text" name="bar_code2" value="<%=WI.fillTextValue("bar_code2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="16"></td>
      <td colspan="2">

        <a href="javascript:PageAction('1','','',true);">
		<img src="../../images/update.gif" border="0"></a><font size="1">click 
        to record barcode information </font> <a href="#">
		<img src="../../images/clear.gif" border="0"
		 onClick="document.form_.id_number2.value='';document.form_.bar_code2.value=''"></a> <font size="1">click to clear</font>

      </td>
    </tr>
    <tr bgcolor="#bbccFF">
      <td height="12" colspan="6" class="thinborderALL" align="center"><font size="2" color="#FF0000"><b>SEARCH</b></font></td>
    </tr>
    

	
    <tr> 
      <td width="3%" height="25" class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderNONE">RF ID </td>
      <td><select name="barcode_id_con" style="font-size:11px">
          <%=parentReg.constructGenericDropList(WI.fillTextValue("barcode_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select></td>
      <td width="26%"><input type="text" name="barcode_id" value="<%=WI.fillTextValue("barcode_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborderNONE">Lastname</td>
      <td><select name="lname_con" style="font-size:11px">
        <%=parentReg.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select> <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderNONE">Login ID </td>
      <td><select name="id_number_con" style="font-size:11px">
        <%=parentReg.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%>
      </select></td>
      <td><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborderNONE">Firstname</td>
      <td class="thinborderRIGHT"><select name="fname_con" style="font-size:11px">
        <%=parentReg.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
       
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25" class="thinborderLEFT">&nbsp;</td>
      <td width="8%" class="thinborderNONE">Sort by</td>
      <td width="27%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=parentReg.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="28%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=parentReg.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="34%" class="thinborderRIGHT"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=parentReg.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="18" colspan="5" class="thinborderLEFT">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM"><a href="javascript:Search();"><img src="../../images/form_proceed.gif" border="0"></a></td>
      <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
  </table>
  

<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="16%" height="25">&nbsp;</td>
      <td width="18%" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Result : <%=iSearchResult%> - Showing(<%=parentReg.getDisplayRange()%>)</b></td>
      <td colspan="2"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/parentReg.defSearchSize;
		if(iSearchResult % parentReg.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="Search();">
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
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="14%" height="25" ><div align="center"><strong><font size="1">LOGIN ID</font></strong></div></td>
      <td width="17%"><center>
        <strong><font size="1">RF ID NUMBER </font></strong>
      </center>      </td>
      <td width="18%"><div align="center"><strong><font size="1">LASTNAME</font></strong></div></td>
      <td width="18%"><div align="center"><strong><font size="1">FIRSTNAME</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">MIDDLE NAME </font></strong></div></td>
      <td width="9%"><center>
        <strong><font size="1">EDIT</font></strong>
      </center>
      </td>
      <td width="11%"><div align="center"><strong><font size="1">REMOVE</font></strong></div></td>
    </tr>
<%for(int i=0; i<vRetResult.size(); i+=6){%>
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+1))%></td>
      <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"xxxxxx")%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td>&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5))%></td>
      <td align="center">&nbsp;

	  <a href='javascript:PageAction("","<%=(String)vRetResult.elementAt(i+1)%>","<%=WI.getStrValue(vRetResult.elementAt(i+2))%>",false);'><img src="../../images/edit.gif" border="0"></a>

	  </td>
      <td align="center">&nbsp;

	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>","<%=WI.getStrValue(vRetResult.elementAt(i+2))%>",true);'><img src="../../images/delete.gif" border="0"></a>

	  </td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"></div></td>
    </tr>
  </table>
<%}//vRetResult is not null
%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="">
<input type="hidden" name="page_action">
<input type="hidden" name="parent_index" value="<%=WI.fillTextValue("parent_index")%>" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>